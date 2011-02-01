//
//  StartViewController.h
//  glogger
//
//  Created by Brice Tebbs on 8/20/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsViewController.h"

@interface StartViewController : UIViewController <nnLoginSettingsViewDelegate>{
    
}

-(IBAction)openRideView;
-(IBAction)openHistoryView;
-(IBAction)openSettings;

@end
