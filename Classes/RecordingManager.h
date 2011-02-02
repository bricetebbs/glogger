//
//  RecordingManager.h
//  glogger
//
//  Created by Brice Tebbs on 8/25/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import "northNitch.h"
#import "Glogger.h"
#import "nnShortSound.h"
#import "nnSmoother.h"
#import "nnCoreDataManager.h"
#import "nnDV.h"
#import "RideHttpService.h"
#import "Recording.h"

typedef struct  {
    double speed;
    double gradient;
    double altitude;
} RecordingStats;

@protocol IndicateRecordStatusProtocol
-(void)showGPSQuality: (NSInteger)status;
-(void)showRecordStatus: (NSInteger)status;
-(void)newStatsDataAvailable;
@end



@interface RecordingManager : NSObject <CLLocationManagerDelegate, RideHttpServiceDelegate> {
    
    nnShortSound* startRecordindSound;
    nnShortSound* stopRecordingSound;
    nnShortSound* pingSound;

    Recording* currentRecording;
    
    nnCoreDataManager *coreDataManager;
    id <nnDVStoreProtocol> preferenceManager;
    
    // Core Location Stuff
    CLLocationManager* locationManager;
    
    //
    // Recording status (maybe move out to seperate class
    //
    BOOL recordIsOn;
    
    CLLocation *lastPoint;
    NSInteger movingCount;    
    NSInteger gpsQuality;
    NSInteger recordStatus;
    
    nnSmoother* smoothSpeed;
    nnSmoother* smoothGradient;
    nnSmoother* smoothAltitude;
    
    
    NSMutableArray* locationBuffer;
    
    id <IndicateRecordStatusProtocol, NSObject> recordStatusDelegate;
}

@property (nonatomic, retain) Recording* currentRecording;
@property (nonatomic, readonly) NSInteger recordStatus;
@property (nonatomic, readonly) NSInteger gpsQuality;


@property (nonatomic, retain)  id <IndicateRecordStatusProtocol, NSObject> recordStatusDelegate;

-(id)initWithCoreData: (nnCoreDataManager*)cd andPreference: (id <nnDVStoreProtocol>) preferenceManager;

-(void)startRecording;
-(void)stopRecording;
-(void)setRecording: (Recording*)r;

-(void)startPinging;
-(void)stopPinging;
-(void)sendPing: (NSString*)command;

-(void)beginNewRecording;
-(void)getStats:(RecordingStats *)stats;

@end
