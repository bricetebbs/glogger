//
//  LiveRecordingViewController.m
//  glogger
//
//  Created by Brice Tebbs on 8/20/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "LiveRecordingViewController.h"
#import "RecordItem.h"
#import "RecordingMapViewController.h"
#import "SettingsViewController.h"

@interface LiveRecordingViewController ()

@property (nonatomic, retain) NSString* processingType;
@property (nonatomic, retain) Recording* currentRecording;
@property (nonatomic, retain) RecordingManager* recordingManager;
@end


@implementation LiveRecordingViewController


@synthesize httpRideService;

@synthesize gpsStatus;
@synthesize recordingStatus;
@synthesize progressMeter;
@synthesize processingText;
@synthesize processingType;
@synthesize currentRecording;
@synthesize recordingManager;
@synthesize rideLabel;
@synthesize preferenceManager;

- (void)dealloc {
    [recordingStatus release];
    [gpsStatus release];
    [httpRideService release];
    [progressMeter release];
    [processingText release];
    [currentRecording release];
    [recordingManager release];
    [rideLabel release];
    [super dealloc];
}


-(void)showGPSQuality:(NSInteger)status
{
    if(status >= 0)
        [gpsStatus setState: status];
}

-(void)showRecordStatus:(NSInteger)status
{
    if(status >= 0)
        [recordingStatus setState: status];
}

-(void)newStatsDataAvailable
{
    
    RecordingStats stats;
     
    [self.recordingManager getStats:&stats];
    
    sCurLabel.text = [NSString stringWithFormat:@"%5.2f",stats.speed * 2.23693629];
    gCurLabel.text = [NSString stringWithFormat:@"%4.2f%",stats.gradient];
    aCurLabel.text = [NSString stringWithFormat:@"%d",(int)(stats.altitude * 3.2808399)];
    
    sMaxLabel.text = [NSString stringWithFormat:@"%5.2f",[self.currentRecording.speed_max doubleValue] * 2.23693629];
    dTotalLabel.text = [NSString stringWithFormat:@"%6.2f",[self.currentRecording.distance_total doubleValue] * 0.000621371192];
    
    nSmpLabel.text = [NSString stringWithFormat:@"%d",[self.currentRecording.samples count]];

     
}

-(void)updateUIDisplay
{
    self.processingText.text = self.processingType;
     
    self.rideLabel.text = self.recordingManager.currentRecording.label;
    
    [self newStatsDataAvailable];
    [self showRecordStatus: self.recordingManager.recordStatus];
    [self showGPSQuality: self.recordingManager.gpsQuality];
    
    if(uploadInProgress)
    {
        progressMeter.hidden = NO;
        progressMeter.progress = uploadPct;
    }
    else {
        progressMeter.hidden = YES;
    }
}


- (void)settingsComplete:(SettingsViewController *)controller cancel: (BOOL) canceled
{
    [self.navigationController dismissModalViewControllerAnimated:YES];
}


-(IBAction)openSettings
{
    SettingsViewController *controller=  [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
    
    controller.delegate = self;
    [self.navigationController presentModalViewController:controller animated:YES];
    [controller release];    
}


-(IBAction)newRecording
{
    [self.recordingManager beginNewRecording];
    self.currentRecording = self.recordingManager.currentRecording;
    [self updateUIDisplay];
}

-(IBAction)pauseRecording
{
    [self.recordingManager stopRecording];
    [self updateUIDisplay];
}

-(IBAction)startRecording
{
    [self.recordingManager startRecording];
    [self updateUIDisplay];
}


-(IBAction)sendPing
{
    [self.recordingManager sendPing: @"UI"];
}


-(IBAction)viewOnWeb
{

    NSString* mapURL = [NSString stringWithFormat:MAP_URL_TEMPLATE, self.currentRecording.guid];
    NSString* url = [NSString stringWithFormat:@"%@/%@", [preferenceManager stringForKey: PREF_SERVER_URL_STRING], mapURL];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]]; 
}


-(IBAction)showMap
{
    
    RecordingMapViewController *mvc = [[RecordingMapViewController alloc] 
                                       initWithNibName:@"RecordingMapViewController" bundle: nil];
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;

    mvc.coreDataManager = adel.coreDataManager;
    mvc.recordingObject =  self.currentRecording;
    [self.navigationController pushViewController:mvc animated:YES];
    [mvc release];
}


#pragma mark -
#pragma mark Upload Data

-(void)gotResponse:(NSObject*)response  forService: (RideHttpService*)service withError: (NSError*) error
{
    uploadInProgress = NO;
    
    if (error) {
        self.processingType = @"Error";
    }
    self.processingType = @"";
    
    [self updateUIDisplay];
    
    nnDebugLog(@"Upload Response=%@ error=%@",response, error);
    
    // Save the managed context so the GUID for the recordingObject is set permanetly. For now we remake on every upload 
    // This facilitates testing but in future maybe it should be made on initial creation of the Recording
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;

    [adel.coreDataManager saveContext];
    
}

-(void)uploadProgress:(double)pct
{
    uploadPct = pct;
    [self updateUIDisplay];
}

-(IBAction)uploadData
{
    
    if (uploadInProgress) {
        return;
    }
  
    
    self.httpRideService = [[RideHttpService alloc] initWithServerString: [preferenceManager stringForKey: PREF_SERVER_URL_STRING]];
    self.httpRideService.ride_delegate = self;
    
    
    [self.httpRideService setAuthenticationCredentials: AUTHENTICATE_URL 
                                              username:[preferenceManager stringForKey: PREF_USERNAME]
                                              password:[preferenceManager stringForKey: PREF_PASSWORD]];
    
    
    uploadInProgress = YES;
  
    self.currentRecording.guid = makeUUID();
    self.processingType = @"Uploading";
    
    [self.httpRideService uploadRide:  self.currentRecording];
    
    [self updateUIDisplay];
}


- (BOOL)textFieldShouldReturn:(UITextField *)theTextField { 
    
    [theTextField resignFirstResponder];
    
    
    self.currentRecording.label = rideLabel.text;
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [adel.coreDataManager saveContext];

    return YES; 
} 



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    self.recordingManager = adel.recordingManager;
    self.recordingManager.recordStatusDelegate = self;
    self.currentRecording = self.recordingManager.currentRecording;
    self.rideLabel.delegate = self;
    self.processingText.text = @"";
    self.progressMeter.hidden = YES;
    [self updateUIDisplay];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear: animated];
    
    self.recordingManager.recordStatusDelegate = nil;
}


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
@end