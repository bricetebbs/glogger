//
//  StartViewController.m
//  glogger
//
//  Created by Brice Tebbs on 8/20/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "StartViewController.h"
#import "SettingsViewController.h"
#import "RideListController.h"
#import "LiveRecordingViewController.h"
#import "gloggerAppDelegate.h"

@implementation StartViewController

- (void)dealloc {
    [super dealloc];
}


-(IBAction)openRideView
{
    LiveRecordingViewController *controller=  [[LiveRecordingViewController alloc] initWithNibName:@"LiveRecordingViewController" bundle:nil];
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    controller.preferenceManager = adel.preferenceManager;
     
    
    if (!adel.recordingManager.currentRecording) 
    {
        [adel.recordingManager beginNewRecording];
    }    
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];    
    
}



-(IBAction)openHistoryView
{
    RideListController *controller=  [[RideListController alloc] initWithNibName:@"RideListController" bundle:nil];
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    controller.coreDataManager = adel.coreDataManager;
    
    [self.navigationController pushViewController:controller animated:YES];
    [controller release];  
    
    
}


-(IBAction)openSettings
{
    SettingsViewController *controller=  [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
   
    controller.delegate = self;
    [self.navigationController presentModalViewController:controller animated:YES];
    [controller release];    
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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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


@end
