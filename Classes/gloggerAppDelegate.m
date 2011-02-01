//
//  gloggerAppDelegate.m
//  glogger
//
//  Created by Brice Tebbs on 7/27/10.
//  Copyright northNitch Studios, Inc. 2010. All rights reserved.
//

#import "gloggerAppDelegate.h"
#import "RideListController.h"
#import "Recording.h"
#import "RecordItem.h"


@interface gloggerAppDelegate ()
@end

@implementation gloggerAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize preferenceManager;
@synthesize coreDataManager;
@synthesize httpRideService;
@synthesize recordingManager;

-(void)dealloc
{
    [coreDataManager release];
    [window release];
    [navigationController release];
    [recordingManager release];
    [preferenceManager release];
    [httpRideService release];
    [super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.

    // Add the navigation controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    
    // Setup access to Core Data
    self.coreDataManager = [[nnCoreDataManager alloc] init];
    [self.coreDataManager setupCoreDataManager:@"glogger.sqlite" model:@"glogger"];
    
   
    
    // Setup Preferences
    preferenceManager = [[nnPreferenceManager alloc] init];
    [self.preferenceManager registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
                                              SERVER_STRING, PREF_SERVER_URL_STRING,
                                              [NSNumber numberWithDouble: 2.2352], PREF_MIN_SPEED,
                                              nil]
     ];
    
    // The recording managr is the calls which actually handles all the recording.
    
    recordingManager = [[RecordingManager alloc] initWithCoreData: self.coreDataManager andPreference: self.preferenceManager];

  
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


/**
 applicationWillTerminate: saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
    
    
    [self.coreDataManager handleAppTermination];
   
}

#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}




@end

