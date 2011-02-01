//
//  SettingsViewController.h
//  glogger
//
//  Created by Brice Tebbs on 8/13/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "nnLoginSettingsViewController.h"
#import "nnDVBoolUISwitch.h"
#import "nnDVStringUIText.h"
#import "nnDVDoubleUISlider.h"

#import "Glogger.h"
#import "nnHTTPService.h"

@interface SettingsViewController : nnLoginSettingsViewController<nnHTTPServiceDelegate,
                                                                    nnDVBoolUISwitchDelegate> {

    IBOutlet nnDVDoubleUISlider* minSpeed;
    IBOutlet nnDVBoolUISwitch* enablePing;
    IBOutlet nnDVBoolUISwitch* enableAutoStop;
    IBOutlet nnDVStringUIText* serverURL;
}

@end
