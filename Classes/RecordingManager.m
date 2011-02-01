//
//  RecordingManager.m
//  glogger
//
//  Created by Brice Tebbs on 8/25/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "RecordingManager.h"

#import "RecordItem.h"

@interface RecordingManager () 

@property (nonatomic, retain) nnCoreDataManager* coreDataManager;
@property (nonatomic, retain) CLLocationManager* locationManager;

@property (nonatomic, assign) id <nnDVStoreProtocol> preferenceManager;

@property (nonatomic, retain) NSMutableArray* locationBuffer;
@property (nonatomic, retain) CLLocation* lastPoint;
@end


@implementation RecordingManager
@synthesize locationBuffer;
@synthesize preferenceManager;
@synthesize coreDataManager;
@synthesize locationManager;
@synthesize currentRecording;
@synthesize recordStatusDelegate;
@synthesize lastPoint;
@synthesize recordStatus;
@synthesize gpsQuality;
-(void)dealloc
{
    [pingSound release];
    [startRecordindSound release];
    [stopRecordingSound release];
    [locationBuffer release];
    [coreDataManager release];
    [locationManager release];
    [recordStatusDelegate release];
    [currentRecording release];
    [super dealloc];
}


-(id)initWithCoreData: (nnCoreDataManager*)cd andPreference: (id <nnDVStoreProtocol>) pm
{
    self = [self init];
    self.coreDataManager = cd;
    self.preferenceManager = pm;
    
    smoothSpeed = [[nnSmoother alloc] initWithWindowSize: 1];
    smoothGradient =  [[nnSmoother alloc] initWithWindowSize: 1];
    smoothAltitude = [[nnSmoother alloc] initWithWindowSize: 1];

    locationBuffer = [[NSMutableArray  alloc] init];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    gpsQuality = -1.0;
    
    locationManager.delegate = self;

    [locationManager startUpdatingLocation];
    
    
    startRecordindSound = [[nnShortSound alloc] initWithSoundName:@"record_start"];
    stopRecordingSound = [[nnShortSound alloc] initWithSoundName:@"record_end"];
    pingSound = [[nnShortSound alloc] initWithSoundName:@"ping"];
    
    return self;
        
}

-(void)beginNewRecording
{
    
    // Make  a new object
    Recording *item = [coreDataManager newObject: @"Recording"];
    

    // Set it up
    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [formatter setDateFormat:@"MM-dd-yyyy hh:mm"];
    [formatter setTimeZone:[NSTimeZone defaultTimeZone]];
    
    NSDate* date = [NSDate date];
    
    NSString* timeStr =[formatter stringFromDate: date];
    
    
    item.label = timeStr;
    item.date = date;
    item.timezone = [[NSTimeZone defaultTimeZone] name];
    item.type = 0;
    item.guid = makeUUID();
    

    
    // Save it
    
    [coreDataManager saveContext];
    
    self.currentRecording = item;
    
    [smoothSpeed reset];
    [smoothGradient reset];
    [smoothAltitude reset];
    

    
}

-(void)setRecording:(Recording *)r
{
    self.currentRecording = r;
    self.lastPoint = nil;
}


-(void)setRecordStatus: (NSInteger)state
{
    recordStatus = state;
    movingCount = 0;
    
    [recordStatusDelegate showRecordStatus: recordStatus];
}



-(void)stopRecording
{
    recordIsOn = NO;
    [locationManager stopUpdatingLocation];
    
    [self setRecordStatus: kRecordStatusStopped];
    [self stopPinging];
    
    [stopRecordingSound playSound];
    
}

-(void)startRecording
{
    gpsQuality = -1.0;
    [locationManager startUpdatingLocation];
    
    recordIsOn = YES;
    
    [self setRecordStatus: kRecordStatusStandby];
    
    if ([preferenceManager boolForKey: PREF_PING_ENABLE]) 
    {
        [self startPinging];
    }
    // [self fakeLocationUpdate];
}


-(void)startPinging
{
     [self performSelector:@selector(sendPing:) withObject: nil afterDelay: 2];
}


-(void)stopPinging
{
    [NSObject cancelPreviousPerformRequestsWithTarget: self selector:@selector(sendPing:) object:nil];
}



-(void)fakeLocationUpdate
{
    [self locationManager: locationManager didUpdateToLocation: locationManager.location fromLocation: locationManager.location];  
    [self performSelector: @selector(fakeLocationUpdate) withObject: nil afterDelay: 3.0];
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
#if 0
    if(([error code] == kCLErrorLocationUnknown) || ([error code] == kCLErrorDenied))
        [locationManager stopUpdatingLocation];
#endif
}

-(void)getStats: (RecordingStats*)stats
{
    stats->speed = smoothSpeed.current;
    stats->gradient = smoothGradient.current;
    stats->altitude = smoothAltitude.current;
}



-(void)recordLocation:(CLLocation*)location speed: (double)spd altitude: (double)alt gradient: (double)grad distance: (double) dist sampleType: (NSInteger)stype;
{


    
    currentRecording.distance_total = [NSNumber numberWithDouble: (dist  + [currentRecording.distance_total doubleValue])];
    
    self.currentRecording.speed_min = [NSNumber numberWithDouble: MIN(spd, [self.currentRecording.speed_min doubleValue])];
    self.currentRecording.speed_max = [NSNumber numberWithDouble: MAX(spd, [self.currentRecording.speed_max doubleValue])];
    self.currentRecording.gradient_min = [NSNumber numberWithDouble: MIN(grad, [self.currentRecording.gradient_min doubleValue])];
    self.currentRecording.gradient_max = [NSNumber numberWithDouble: MAX(grad, [self.currentRecording.gradient_max doubleValue])];
    self.currentRecording.elevation_min = [NSNumber numberWithDouble: MIN(alt, [self.currentRecording.elevation_min doubleValue])];
    self.currentRecording.elevation_max = [NSNumber numberWithDouble: MAX(alt, [self.currentRecording.elevation_max doubleValue])];
 
    RecordItem *item = [coreDataManager newObject: @"RecordItem"];
    
    
    item.timestamp = location.timestamp;
    item.recording = self.currentRecording;
    item.type = [NSNumber numberWithInt:stype];
    item.altitude = [NSNumber numberWithDouble: alt];
    item.latitude = [NSNumber numberWithDouble: location.coordinate.latitude];
    item.longitude = [NSNumber numberWithDouble: location.coordinate.longitude];
    item.accuracy = [NSNumber numberWithDouble: location.horizontalAccuracy];
    item.speed = [NSNumber numberWithDouble: spd ];
    item.gradient = [NSNumber numberWithDouble: grad];
    item.distance = [NSNumber numberWithDouble: [self.currentRecording.distance_total doubleValue]];
    
    
    
    [coreDataManager saveContext];
   
}

-(void)updateGPSQuality: (CLLocation*)location
{
    
    NSInteger quality;
    if(location.horizontalAccuracy <= 10)
    {
        quality = kGPSStatusGood;
    }
    else if (location.horizontalAccuracy <= 100) 
    {
        quality = kGPSStatusOK;
    }
    else 
    {
        quality = kGPSStatusPoor;
    }
    
    if(quality != gpsQuality)
    {
        gpsQuality = quality;
        [recordStatusDelegate showGPSQuality: gpsQuality];
    }
    
    
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    if (!recordIsOn) {
        [locationManager stopUpdatingLocation];
    }
    
    if(newLocation.speed < 0)
    {
        return;
    }
    
    [self updateGPSQuality: newLocation];
    
    [smoothSpeed addValue: newLocation.speed];
    [smoothAltitude addValue: newLocation.altitude];
    

    // Calculate gradient
    if(newLocation.horizontalAccuracy < 20.0 && newLocation.verticalAccuracy < 20.0)
    {
        if(self.lastPoint)
        {
            double gradDist = [newLocation distanceFromLocation: lastPoint];
            double altDiff = newLocation.altitude - lastPoint.altitude;
            if (gradDist > 0.0)
            {
                nnDebugLog(@"Dst=%f Ele=%f",gradDist, altDiff) ;
                [smoothGradient addValue:  100.0 * altDiff/gradDist];
            }
        }
        self.lastPoint = newLocation;
    }
    else 
    {
        self.lastPoint = nil;
    }
    
    BOOL stype = kSampleNormal;
    
    double minSpeed = [preferenceManager doubleForKey: PREF_MIN_SPEED];
    BOOL autoStop = [preferenceManager boolForKey: PREF_AUTOSTOP_ENABLE];
    
    double segDist = [newLocation distanceFromLocation: oldLocation];
    if (self.currentRecording && recordIsOn) 
    {
        // If timestamp didn't change ignore this.
        if(oldLocation.timestamp != newLocation.timestamp)
        {
            if (recordStatus == kRecordStatusStandby) 
            {
                if(newLocation.speed < minSpeed && autoStop)
                {
                    movingCount = 0;
                    [self.locationBuffer removeAllObjects];
                }
                else 
                {
                    movingCount++;
                    if(movingCount > MIN_START_SAMPLES || !autoStop)
                    {
                        [startRecordindSound playSound];
                        [self setRecordStatus: kRecordStatusRunning];
                        stype = kSampleStart;
                        for(NSArray* lvec in self.locationBuffer)
                        {
                            [self recordLocation: [lvec objectAtIndex:0] 
                                           speed: [[lvec objectAtIndex:1] doubleValue]
                                        altitude: [[lvec objectAtIndex:2] doubleValue]
                                        gradient: [[lvec objectAtIndex:3] doubleValue]
                                        distance: [[lvec objectAtIndex:4] doubleValue]
                                      sampleType: stype];
                            stype = kSampleNormal;
                        }
                    }
                    else {
                        [self.locationBuffer addObject: [NSArray arrayWithObjects: 
                                                         newLocation, 
                                                         [smoothSpeed asNSNumber],
                                                         [smoothAltitude asNSNumber],
                                                         [smoothGradient asNSNumber],
                                                         [NSNumber numberWithDouble: segDist],
                                                         nil]];
                    }
                    
                }
            }
            
            else if(recordStatus == kRecordStatusRunning)
            {
                if (newLocation.speed < minSpeed && autoStop) 
                {
                    movingCount++;
                    if (movingCount > MIN_STOP_SAMPLES) 
                    {
                        [stopRecordingSound playSound];
                        [self setRecordStatus: kRecordStatusStandby];
                    }
                }
                else 
                {
                    movingCount = 0;
                }
            }
            
            
            if(recordStatus == kRecordStatusRunning)
            {
                [self recordLocation:newLocation speed: smoothSpeed.current altitude: smoothAltitude.current gradient: smoothGradient.current distance: segDist sampleType: stype];
            }
        }
    }
    
    [recordStatusDelegate newStatsDataAvailable];
}

#pragma mark -
#pragma mark Ping Stuff
 

-(void)gotResponse:(NSObject*)response forService: (RideHttpService*)service withError: (NSError*) error
{
    nnDebugLog(@"Server PING Response=%@",response);
    nnDebugLog(@"Error=%@",error);
    
    [service release];
}


-(void)sendPing: (NSString*)command
{
    
    RideHttpService* rideService  = [[RideHttpService alloc] initWithServerString:[preferenceManager stringForKey: PREF_SERVER_URL_STRING]];
    rideService.ride_delegate = self;
    
    
    [rideService setAuthenticationCredentials: AUTHENTICATE_URL 
                                              username:[preferenceManager stringForKey: PREF_USERNAME]
                                              password:[preferenceManager stringForKey: PREF_PASSWORD]];
    
    
    
    [rideService sendPing: locationManager.location];
    
    // Queue up another ping
    if (![command isEqualToString: @"UI"])
    {
        if (recordIsOn && [preferenceManager boolForKey: PREF_PING_ENABLE])
            [self performSelector:@selector(sendPing:) withObject: nil afterDelay: 15]; // 60*5
    }
}


@end
