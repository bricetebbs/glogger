//
//  RecordingDetailViewController.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "Recording.h"
#import "gloggerAppDelegate.h"
#import "nnStatusIndicator.h"
#import "nnCoreDataBackgroundThreadManager.h"
#import "RideHttpService.h"
#import "SettingsViewController.h"


@interface RecordingDetailViewController : UIViewController <MFMailComposeViewControllerDelegate,
                                                            RideHttpServiceDelegate,
                                                            nnLoginSettingsViewDelegate,
                                                             IndicateRecordStatusProtocol> 
{
    Recording* recordingObject;
    NSManagedObjectID* recordingID;
    Recording* backgroundRecordingObject;

    nnCoreDataManager *coreDataManager;
    
    NSString *backgroundMessage;
    nnCoreDataBackgroundThreadManager* backgroundThreadManager;
    id <nnPreferenceStoreProtocol> preferenceManager;
    
    
    UITextView* statsDump;
    UIActivityIndicatorView *processingSpinner;
    UILabel *processingText;
    NSString *processingType;
    UIProgressView *progressMeter;
                                                                 
    nnStatusIndicator* gpsStatus;
    nnStatusIndicator* recordingStatus;
    
    id <IndicateRecordStatusProtocol> recordStatusDelegate;
    
    IBOutlet UIButton* startButton;
    IBOutlet UIButton* stopButton;
    IBOutlet UIButton* sendButton;
    IBOutlet UIButton* mapButton;
    IBOutlet UIButton* uploadButton;
    
    IBOutlet UIButton* settingsButton;
    
    IBOutlet UIView* statsPanel;
    IBOutlet UILabel* dTotalLabel;
    IBOutlet UILabel* tTotalLabel;
    IBOutlet UILabel* sMaxLabel;
    IBOutlet UILabel* sAvgLabel;
    IBOutlet UILabel* eDeltaLabel;
    IBOutlet UILabel* gMaxLabel;
    IBOutlet UILabel* gMinLabel;
    
    
    BOOL uploadInProgress;
    double uploadPct;
    

    NSMutableArray *uploadSamples;
    NSInteger lastUploadIndex;
    NSString *segmentGuid;
    
    
}


@property (nonatomic, retain) nnCoreDataManager *coreDataManager;


@property (nonatomic, assign) id <nnPreferenceStoreProtocol>  preferenceManager;
@property (nonatomic, retain) NSMutableArray *uploadSamples;
@property (nonatomic, retain) NSString* segmentGuid;


@property (nonatomic, retain) IBOutlet UITextView* statsDump;
@property (nonatomic, retain) IBOutlet nnStatusIndicator* gpsStatus;
@property (nonatomic, retain) IBOutlet nnStatusIndicator* recordingStatus;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *processingSpinner;
@property (nonatomic, retain) IBOutlet UILabel *processingText;
@property (nonatomic, retain) IBOutlet UIProgressView *progressMeter;

-(void)setTheRecordingObject: (Recording*) r;

-(IBAction)startRecording;
-(IBAction)stopRecording;
-(IBAction)showMap;
-(IBAction)uploadData;
-(IBAction)computeStats;
-(IBAction)filterSamples;
-(IBAction)processRecording;
-(IBAction)sendFile;
-(IBAction)viewOnWeb;
-(IBAction)openSettings;
@end

