//
//  RecordingDetailViewController.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "RecordingDetailViewController.h"
#import "RecordingMapViewController.h"
#import "SettingsViewController.h"
#import "gloggerAppDelegate.h"
#import "Glogger.h"


@interface RecordingDetailViewController ()

@property (nonatomic, retain) NSString* backgroundMessage;
@property (nonatomic, retain) NSString* processingType;
@property (nonatomic, retain) Recording* recordingObject;

@property (nonatomic, retain) Recording* backgroundRecordingObject;

@property (nonatomic, retain) NSManagedObjectID* recordingID;

@property (nonatomic, retain) nnCoreDataBackgroundThreadManager *backgroundThreadManager;

@end

@implementation RecordingDetailViewController

@synthesize recordingObject;
@synthesize backgroundRecordingObject;
@synthesize recordingID;
@synthesize coreDataManager;
@synthesize statsDump;
@synthesize backgroundMessage;
@synthesize backgroundThreadManager;
@synthesize gpsStatus;
@synthesize recordingStatus;
@synthesize processingSpinner;
@synthesize progressMeter;
@synthesize processingText;
@synthesize processingType;
@synthesize uploadSamples;
@synthesize segmentGuid;
@synthesize preferenceManager;

- (void)dealloc {
    [recordingStatus release];
    [gpsStatus release];
    [uploadSamples release];
    [segmentGuid release];
    [backgroundMessage release];
    [processingSpinner release];
    [progressMeter release];
    [processingText release];
    [recordingObject release];
    [backgroundThreadManager release];
    [backgroundRecordingObject release];
    [recordingID release];
    [coreDataManager release];
    [statsDump release];
    [super dealloc];
}

-(void)setTheRecordingObject: (Recording*) r
{
    self.recordingObject = r;
    self.recordingID = [r objectID];
}



-(IBAction)showMap
{
    
    RecordingMapViewController *mvc = [[RecordingMapViewController alloc] 
                                       initWithNibName:@"RecordingMapViewController" bundle: nil];
    mvc.coreDataManager = coreDataManager;
    mvc.recordingID = recordingID;
    [self.navigationController pushViewController:mvc animated:YES];
    [mvc release];
}

-(void)showGPSQuality:(NSInteger)status
{
    [gpsStatus setState: status];
}

-(void)showRecordStatus:(NSInteger)status
{
    [recordingStatus setState: status];
}



-(void)openSettings
{
    SettingsViewController *controller=  [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    [controller setupPreferences: preferenceManager usernameKey: PREF_USERNAME passwordKey: PREF_PASSWORD];
    controller.delegate = self;
    [self.navigationController presentModalViewController:controller animated:YES];
    [controller release];    
}

-(void)updateUIDisplay
{
    self.statsDump.text = backgroundMessage;
    self.processingText.text = self.processingType;
    
    
    self.recordingObject = (Recording*)[coreDataManager.managedObjectContext objectWithID: recordingID];
    // Have to refresh the object since we may have messed with it (or its children in the background thread
    
    [coreDataManager.managedObjectContext refreshObject: self.recordingObject mergeChanges:NO];
    
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    BOOL canShowData = [self.recordingObject.stats_computed boolValue] && [self.recordingObject.points_filtered boolValue];
    canShowData = canShowData && ([adel.recordingManager recordingObject] == nil);
    mapButton.hidden = !canShowData;
    sendButton.hidden = !canShowData;
    statsPanel.hidden = !canShowData;
    uploadButton.hidden = !canShowData;
    
    
    
    stopButton.hidden = !recordingID || [adel.recordingManager recordingObject] != recordingID;
    startButton.hidden = [adel.recordingManager recordingObject] != nil;
    
    if(uploadInProgress)
    {
        progressMeter.hidden = NO;
        progressMeter.progress = uploadPct;
    }
    else {
        progressMeter.hidden = YES;
    }

    if (canShowData) {

        
        dTotalLabel.text = [NSString stringWithFormat:@"%6.3fmi",[self.recordingObject.distance_total doubleValue] * 0.000621371192];
        NSTimeInterval timeElapsed = [self.recordingObject.time_max timeIntervalSinceDate:self.recordingObject.time_min];
        NSInteger hours = timeElapsed/3600.0;
        timeElapsed = timeElapsed - hours * 3600;
        NSInteger mins = timeElapsed/60.0;
        timeElapsed = timeElapsed - mins* 60;
        NSInteger secs = timeElapsed;
        tTotalLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,mins,secs];
        
        sMaxLabel.text = [NSString stringWithFormat: @"%5.2fmph",[self.recordingObject.speed_max doubleValue] * 2.23693629];
        sAvgLabel.text = [NSString stringWithFormat: @"%5.2fmph",[self.recordingObject.speed_avg doubleValue] * 2.23693629];
                          
        double edelta = [self.recordingObject.elevation_max doubleValue] - [self.recordingObject.elevation_min doubleValue];
                          
        eDeltaLabel.text = [NSString stringWithFormat:@"%dft",(int)(edelta * 3.2808399)];
        gMaxLabel.text = [NSString stringWithFormat:@"%5.2f%%",[self.recordingObject.gradient_max doubleValue]];
        gMinLabel.text = [NSString stringWithFormat:@"%5.2f%%",[self.recordingObject.gradient_min doubleValue]];
    }
}

-(void)finishedProcessing
{
    [self updateUIDisplay];
    [self.processingSpinner stopAnimating];
}


#pragma mark -
#pragma mark Sample Filtering Code
-(NSInteger)trimTailEnd
{
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:NO];
    NSArray *items = [[self.backgroundRecordingObject.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]];
    
    int i;
    
    NSInteger firstKeeper= -1;
    NSInteger keeperCount =0;
    RecordItem* currentItem = nil;
    
    NSInteger samplesTrimmed = 0;
    double minSpeed = [preferenceManager doubleForKey: PREF_MIN_SPEED];
    for (i=0; i <[items count] ; i++)
    {
        currentItem = [items objectAtIndex: i];
        
        if([currentItem.speed doubleValue] > minSpeed)
        {
            if(firstKeeper == -1)
                firstKeeper = i;
            keeperCount++;
        }
        else {
            keeperCount = 0;
            firstKeeper = -1;
        }
        if (keeperCount >= MIN_START_SAMPLES) {
            break;
        }
    }
    if (firstKeeper != -1) {
        for (i=0; i < firstKeeper ; i++)
        {
            currentItem = [items objectAtIndex: i];
            [self.backgroundThreadManager.backgroundManagedObjectContext deleteObject:currentItem];
            samplesTrimmed++;
        }
    }
    
    return samplesTrimmed;
}

double distsqr(RecordItem* p1, RecordItem* p2)
{
    
    double lat_diff = [p1.latitude doubleValue] -[p2.latitude doubleValue];
    double long_diff = [p1.longitude doubleValue] -[p2.longitude doubleValue];
    
    return lat_diff*lat_diff + long_diff*long_diff;
}



-(void)filterSamplesWorker
{
     
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    NSArray *items = [[self.backgroundRecordingObject.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]];
    
    if (![items count]) {
        return;
    }
    
    self.processingType=@"Filtering Samples";
    [self performSelectorOnMainThread:@selector(updateUIDisplay) withObject:nil waitUntilDone:YES];
    

    NSMutableArray* deletedItems = [[NSMutableArray alloc] init];
    
    RecordItem* lastItem = nil;
    RecordItem* currentItem = nil;
    RecordItem* nextItem = nil;
    
    // For debuging [NSThread sleepForTimeInterval:10];
    
    BOOL deleted = NO;
    NSInteger dupCount = 0;
    int i;
    
    for (i=0; i <[items count] ; i++)
    {
        deleted = NO;
        currentItem = [items objectAtIndex: i];
              
        nextItem = nil;
        if(i < [items count] - 1)
            nextItem = [items objectAtIndex: i+1];
        
        if (currentItem && lastItem && nextItem) {
            double dCL = distsqr(currentItem, lastItem);
            double dLN = distsqr(lastItem, nextItem);
            double dCN =  distsqr(currentItem, nextItem);
        
            if(i==1 || dCL == 0 && dCN == 0 || (dCL == 0 && dCN==dLN) || (dCN==0) && (dCL==dLN))
            {
                [deletedItems addObject: currentItem];
                deleted = YES;
                dupCount++;
            }
            else if(dLN < MAX(dCL, dCN))
            {   
                [deletedItems addObject: currentItem];
                deleted = YES;
            }
        }
        if (!deleted) {
            lastItem = currentItem;
        }
    }
    
    
    
    NSInteger delCount = [deletedItems count];
    
    for(RecordItem* item in deletedItems)
    {
        [self.backgroundThreadManager.backgroundManagedObjectContext  deleteObject:item];
    }
    
   
    [deletedItems release];
    
    NSInteger trimCount = [self trimTailEnd];
   
     
    backgroundRecordingObject.points_filtered = [NSNumber numberWithBool: YES];
    
    self.backgroundMessage = [NSString stringWithFormat:@"DelCount=%d TrimCount=%d", delCount, trimCount];
    
    NSError *error;
    if (![self.backgroundThreadManager.backgroundManagedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    self.processingType=@"";
    [self performSelectorOnMainThread:@selector(updateUIDisplay) withObject:nil waitUntilDone:YES];
    

}

#pragma Mark -
#pragma mark Stats Computing code

double findMedian(double* array, int size)
{
    double windowCopy[100];
    int i;
    double median;
    for ( i=0; i < size; i++) {
        windowCopy[i] = array[i];
    }
    for (int iter = 0; iter <= size/2; iter++) {
        double min = MAXFLOAT;
        int minIdx = -1;
        for (i = iter; i < size; i++) {
            if(windowCopy[i] < min)
            {
                min=windowCopy[i];
                minIdx=i;
            }
        }
        windowCopy[minIdx] = windowCopy[iter];
        median = min; // Or our best guess so far
    }
    return median;
}

void medianFilter(double *array, int size, int window)
{
    double medianWindow[100];
    NSInteger nextInsert = 0;
    
    int count=0;
    int i;
    for (i = 0; i< size; i++) {
        medianWindow[nextInsert] = array[i];
        nextInsert= (nextInsert+ 1) % window;
        
        count++;
        if (count>= window)
        {
            array[i-window/2] = findMedian(medianWindow,window);
        }
    }
}

void smoothWindow(double *array, int size, int window)
{
    double sum;
    int count =0;
    int i;
    for (i = 0; i< size; i++) {
        sum+=array[i];
        count++;
        if (count>= window)
        {
            array[i-window/2] = sum/window;
            sum -= array[i-(window-1)];
        }
    }
}


-(void)computeStatsWorker
{
    
       
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    NSArray *items = [[self.backgroundRecordingObject.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]];

    if (![items count]) 
        return;
    

    
    self.processingType=@"Computing Stats";
    
    [self performSelectorOnMainThread:@selector(updateUIDisplay) withObject:nil waitUntilDone:YES];
  
    
    
    int i = 0;
    float totalDist = 0.0;
    float speedMin = 0.0;
    float speedAvg = 0.0;
    float speedMax = 0.0;
    float elevationMin = 0.0;
    float elevationMax = 0.0;
    float gradientMin = 0.0;
    float gradientMax = 0.0;
    
    RecordItem* lastItem = nil;
    RecordItem* currentItem = nil;

    CLLocation* lastLoc = [CLLocation alloc];
    CLLocation* currentLoc = [CLLocation alloc];
    
    double* speeds=malloc(sizeof(double)*[items count]);
    double* gradients=malloc(sizeof(double)*[items count]);

    
    for (i=0; i <[items count] ; i++)
    {
        currentItem = [items objectAtIndex: i];
         
        double segDist= 0.0;
        double altDiff=0.0;
        double timeDiff= 0.0;
        double speed = 0.0;
        double gradient = 0.0;
        
        
        if (i==0) {
            elevationMax = [currentItem.altitude doubleValue];
            elevationMin = [currentItem.altitude doubleValue];
        }
        
        else {
            elevationMax = MAX(elevationMax, [currentItem.altitude doubleValue]);
            elevationMin = MIN(elevationMin, [currentItem.altitude doubleValue]);
        }

        [currentLoc initWithLatitude:  [currentItem.latitude doubleValue] longitude: [currentItem.longitude doubleValue]];
      
        if(lastItem) 
        {
            [lastLoc initWithLatitude: [lastItem.latitude doubleValue] longitude: [lastItem.longitude doubleValue]];
            segDist = [lastLoc distanceFromLocation: currentLoc];
            totalDist += segDist;
            altDiff = [currentItem.altitude doubleValue] - [lastItem.altitude doubleValue];
            gradient = 100.0 * altDiff/segDist;
            timeDiff = [currentItem.timestamp timeIntervalSince1970] - [lastItem.timestamp timeIntervalSince1970];
            speed = segDist/timeDiff;
        }
        
        speeds[i] = speed;
        gradients[i] = gradient;
        currentItem.distance = [NSNumber numberWithDouble: totalDist];
        currentItem.speed = [NSNumber numberWithDouble:speed];
        currentItem.gradient = [NSNumber numberWithDouble:gradient];
        
        lastItem = currentItem;
        
 //       nnDebugLog(@"(%@,%@) spd=%f d=%f e=%@",currentItem.latitude, currentItem.longitude, speed, segDist, currentItem.accuracy);
    }
    

    
    [lastLoc release];
    [currentLoc release];

    
    smoothWindow(speeds, [items count], 9);
    medianFilter(gradients, [items count], 19);
    smoothWindow(gradients, [items count], 9);
    
    for (i=0; i <[items count] ; i++)
    {
        if (i == 0) {
            speedMax = speeds[i];
            speedMin = speeds[i];
            gradientMax = gradients[i];
            gradientMin = gradients[i];
        }
        else {
            speedMax = MAX(speedMax, speeds[i]);
            speedMin = MIN(speedMin, speeds[i]);
            gradientMax = MAX(gradientMax, gradients[i]);
            gradientMin = MIN(gradientMin, gradients[i]);
        }

        speedAvg += speeds[i];
        currentItem = [items objectAtIndex: i];
        currentItem.speed = [NSNumber numberWithDouble: speeds[i]];
        currentItem.gradient = [NSNumber numberWithDouble: gradients[i]];
    }
    
    speedAvg = speedAvg/[items count];
    free(speeds);
    free(gradients);


    NSError *error;
    
    self.backgroundRecordingObject.stats_computed = [NSNumber numberWithBool: YES];
    self.backgroundRecordingObject.distance_total = [NSNumber numberWithDouble:totalDist];
    
    self.backgroundRecordingObject.speed_max = [NSNumber numberWithDouble:speedMax];
    self.backgroundRecordingObject.speed_min = [NSNumber numberWithDouble:speedMin];
    self.backgroundRecordingObject.speed_avg = [NSNumber numberWithDouble:speedAvg];
    
    self.backgroundRecordingObject.elevation_max = [NSNumber numberWithDouble: elevationMax];
    self.backgroundRecordingObject.elevation_min = [NSNumber numberWithDouble: elevationMin];
    
    self.backgroundRecordingObject.gradient_max = [NSNumber numberWithDouble:gradientMax];
    self.backgroundRecordingObject.gradient_min = [NSNumber numberWithDouble:gradientMin];
    
    self.backgroundRecordingObject.time_max = ((RecordItem*)[items lastObject]).timestamp;
    self.backgroundRecordingObject.time_min = ((RecordItem*)[items objectAtIndex:0]).timestamp;
    
    
    if (![self.backgroundThreadManager.backgroundManagedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    
    self.processingType=@"";
    [self performSelectorOnMainThread:@selector(updateUIDisplay) withObject:nil waitUntilDone:YES];
    

}

#pragma mark -
#pragma mark Processing Glue
-(void)processRecordingWrapper
{
    self.backgroundThreadManager = [[nnCoreDataBackgroundThreadManager alloc] initWithCoreDataManager: coreDataManager blockInput: YES];
    
    [backgroundThreadManager release];
    
    // Get object from background context
    
    self.backgroundRecordingObject = (Recording*)[self.backgroundThreadManager.backgroundManagedObjectContext objectWithID: self.recordingID];
    
    [self.backgroundThreadManager.backgroundManagedObjectContext refreshObject:self.backgroundRecordingObject mergeChanges:NO];
    
    
    [self filterSamplesWorker];
    [self computeStatsWorker];
    
    [self performSelectorOnMainThread:@selector(finishedProcessing) withObject:nil waitUntilDone:YES];

    
    self.backgroundThreadManager = nil;
}

-(IBAction)stopRecording
{
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [adel.recordingManager stopRecording];
    
    if(self.backgroundThreadManager)
        return;
    
    [self.processingSpinner startAnimating];
    self.statsDump.text = @"";
    [self performSelectorInBackground:@selector(processRecordingWrapper) withObject:nil];
    
}

-(IBAction)startRecording
{
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [adel.recordingManager setRecording: recordingObject];
    [adel.recordingManager startRecording];
    
    [self updateUIDisplay];
}



-(IBAction)processRecording
{
    if(self.backgroundThreadManager)
        return;
    
    [self.processingSpinner startAnimating];
    
    self.statsDump.text = @"";
    
    [self performSelectorInBackground:@selector(processRecordingWrapper) withObject:nil];
}


#pragma mark -
#pragma mark Stats Computing Glue


-(void)computeStatsWrapper
{
    self.backgroundThreadManager = [[nnCoreDataBackgroundThreadManager alloc] initWithCoreDataManager: coreDataManager blockInput: YES];
    
    [backgroundThreadManager release];
    
    // Get object from background context
    
    self.backgroundRecordingObject = (Recording*)[self.backgroundThreadManager.backgroundManagedObjectContext objectWithID: self.recordingID];
    
    [self computeStatsWorker];
    
    [self performSelectorOnMainThread:@selector(finishedProcessing) withObject:nil waitUntilDone:YES];

    
    self.backgroundThreadManager = nil;
}




-(IBAction)computeStats;
{
    if(self.backgroundThreadManager)
        return;
    
    [self.processingSpinner startAnimating];
    
    self.statsDump.text = @"";
    
    [self performSelectorInBackground:@selector(computeStatsWrapper) withObject:nil];
}


#pragma mark -
#pragma mark Sample Filtering Glue

-(void)filterSamplesWrapper
{
    // This runs in BACKGROUND
    
    self.backgroundThreadManager = [[nnCoreDataBackgroundThreadManager alloc] initWithCoreDataManager: coreDataManager blockInput: YES];
    [backgroundThreadManager release];
    
    // Get object from background context
    
    self.backgroundRecordingObject = (Recording*)[self.backgroundThreadManager.backgroundManagedObjectContext objectWithID: self.recordingID];
    [self filterSamplesWorker];
    [self performSelectorOnMainThread:@selector(finishedProcessing) withObject:nil waitUntilDone:YES];

    self.backgroundThreadManager = nil;
}



-(IBAction)filterSamples
{
    if(self.backgroundThreadManager )
        return;
    
    [self.processingSpinner startAnimating];
    
    self.statsDump.text = @"";
    
    [self performSelectorInBackground:@selector(filterSamplesWrapper) withObject:nil];
}





#pragma mark -
#pragma mark Gpx File Stuff
-(void)outputRecording: (Recording*)recordToWrite  AsGPXFile: (NSString*)path
{
    
    [[NSFileManager defaultManager] createFileAtPath: path contents:nil attributes:nil];
    NSFileHandle* outFile = [NSFileHandle fileHandleForWritingAtPath:path];
    
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    NSArray *items = [[recordToWrite.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]];
    
    
    NSString *str = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n";
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    str = [NSString stringWithFormat: @"<gpx xmlns=\"http://www.topografix.com/GPX/1/1\" xmlns:xalan=\"http://xml.apache.org/xalan\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" creator=\"%@\" version=\"1.1\">\n",
           APP_NAME];
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    str = @"   <trk>\n";
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    str = [NSString stringWithFormat:@"       <name>%@</name>\n", recordToWrite.label];
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    str = [NSString stringWithFormat:@"       <desc>%@</desc>\n", recordToWrite.label];
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    
    
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"yyyy-MM-dd'T'hh:mm:ss.SSSS'Z'"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    
    for (RecordItem *item in items)
    {
        str = [NSString stringWithFormat:@"       <trkpt lat=\"%f\" lon=\"%f\">\n", [item.latitude doubleValue], [item.longitude doubleValue]];
        [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
        
        str = [NSString stringWithFormat:@"          <ele>%f</ele>\n",[item.altitude doubleValue]];
        [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
        
        // 2002-02-10T21:01:29.250Z
        
        NSString* timeStr =[formatter stringFromDate: item.timestamp];
        
        
        str = [NSString stringWithFormat:@"          <time>%@</time>\n",timeStr];
        [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
        
        str = [NSString stringWithFormat:@"       </trkpt>\n"];
        [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    }
    
    str = @"   </trk>\n";
    
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    str = @"</gpx>\n";
    
    [outFile writeData:[ str dataUsingEncoding: NSUTF8StringEncoding]];
    
    [outFile closeFile];
    
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{   
    [self dismissModalViewControllerAnimated:YES];
}

-(IBAction)sendFile
{
    NSString* outPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
                         stringByAppendingPathComponent: @"track.out"];
    nnDebugLog(@"Outpath=%@",outPath);
    
    [self outputRecording:recordingObject AsGPXFile:outPath];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    picker.mailComposeDelegate = self;
    [picker setSubject:[NSString stringWithFormat: @"Track From %@", APP_NAME]];
    
    NSData *data = [NSData dataWithContentsOfFile: outPath];
    [picker addAttachmentData:data mimeType:@"text/xml" fileName:@"track.gpx"];
    
    [picker setMessageBody:@"This is a track in GPX Format." isHTML:NO];
    
    [self presentModalViewController: picker animated:YES];
    [picker release];
    
}



#pragma mark -
#pragma mark Upload Data


-(IBAction)viewOnWeb
{
    NSString* mapURL = [NSString stringWithFormat:MAP_URL_TEMPLATE, self.recordingObject.guid];
    NSString* url = [NSString stringWithFormat:@"%@/%@", SERVER_STRING, mapURL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]; 
}
                                                                    
-(void)gotResponse:(NSObject*)response  withError: (NSError*) error
{
    uploadInProgress = NO;
    [self updateUIDisplay];
    
    // This is so the GUID for the recordingObject is set permanetly. For now we remake on every upload 
    // This facilitates testing but in future maybe it should be made on initial creation of the Recording
    
    NSError* dbError;
    if (![self.coreDataManager.managedObjectContext save:&dbError]) {
        NSLog(@"Whoops, couldn't save: %@", [dbError localizedDescription]);
    }
    
}
     
-(void)uploadProgress:(double)pct
{
    uploadPct = pct;
    [self updateUIDisplay];
}

-(IBAction)uploadData
{
    RideHttpService* rideService = [[RideHttpService alloc] initWithServerString:SERVER_STRING];
    rideService.ride_delegate = self;
    
    
    [rideService setAuthenticationCredentials: AUTHENTICATE_URL 
                                              username:[preferenceManager stringForKey: PREF_USERNAME]
                                              password:[preferenceManager stringForKey: PREF_PASSWORD]];
    
    
    uploadInProgress = YES;
    self.recordingObject.guid = makeUUID();
    
    [rideService uploadRide: recordingObject];

    
}


- (void)settingsComplete:(SettingsViewController *)controller cancel: (BOOL) canceled
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Details";
    self.statsDump.font = [UIFont fontWithName:@"Helvetica" size:10];
    self.processingText.text = @"";
    self.progressMeter.hidden = YES;
    [self updateUIDisplay];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)showStats:(RecordingStats *)stats
{
}

@end
