//
//  LiveRecordingViewController.h
//
//  Created by Brice Tebbs on 8/20/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recording.h"
#import "gloggerAppDelegate.h"
#import "nnStatusIndicator.h"
#import "SettingsViewController.h"
#import "RideHttpService.h"


@interface LiveRecordingViewController : UIViewController <RideHttpServiceDelegate, nnLoginSettingsViewDelegate, IndicateRecordStatusProtocol, UITextFieldDelegate>
{
    UILabel *processingText;
    NSString *processingType;
    UIProgressView *progressMeter;
    
    nnStatusIndicator* gpsStatus;
    nnStatusIndicator* recordingStatus;
    
    IBOutlet UIButton* startButton;
    IBOutlet UIButton* pauseButton;

    IBOutlet UIButton* mapButton;
    IBOutlet UIButton* uploadButton;
    

    IBOutlet UILabel* dTotalLabel;
    IBOutlet UILabel* sCurLabel;
    
    IBOutlet UILabel* sMaxLabel;
    IBOutlet UILabel* gCurLabel;
    
    IBOutlet UILabel* aCurLabel;
    
    IBOutlet UILabel* nSmpLabel;

    IBOutlet UITextField* rideLabel;
    
    RideHttpService* httpRideService;
    BOOL uploadInProgress;
    double uploadPct;
    
    Recording* currentRecording;
    RecordingManager* recordingManager;
    
}


@property (nonatomic, retain) IBOutlet nnStatusIndicator* gpsStatus;
@property (nonatomic, retain) IBOutlet nnStatusIndicator* recordingStatus;
@property (nonatomic, retain) IBOutlet UILabel *processingText;
@property (nonatomic, retain) IBOutlet UIProgressView *progressMeter;
@property (nonatomic, retain)  IBOutlet UITextField* rideLabel;

@property (nonatomic, assign) id <nnDVStoreProtocol>  preferenceManager;
@property (nonatomic, retain) RideHttpService *httpRideService;


-(IBAction)newRecording;
-(IBAction)startRecording;
-(IBAction)pauseRecording;

-(IBAction)openSettings;

-(IBAction)uploadData;
-(IBAction)sendPing;
-(IBAction)showMap;


@end
