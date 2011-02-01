//
//  gloggerAppDelegate.h
//  glogger
//
//  Created by Brice Tebbs on 7/27/10.
//  Copyright northNitch Studios, Inc. 2010. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

#import "northNitch.h"
#import "Glogger.h"


#import "nnCoreDataManager.h"
#import "nnPreferenceManager.h"
#import "RideHttpService.h"
#import "RideListController.h"
#import "RecordingManager.h"
#import "Recording.h"



@interface gloggerAppDelegate : NSObject <UIApplicationDelegate> 
{
    
    UIWindow *window;
    UINavigationController *navigationController;
    
@private
    nnCoreDataManager *coreDataManager;
    nnPreferenceManager *preferenceManager;
    RecordingManager* recordingManager;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@property (nonatomic, retain) nnPreferenceManager* preferenceManager;
@property (nonatomic, retain) RideHttpService *httpRideService;
@property (nonatomic, retain) nnCoreDataManager* coreDataManager;

@property (nonatomic, retain) RecordingManager* recordingManager;


@end
