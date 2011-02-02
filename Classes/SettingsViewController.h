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
                                                                    nnDVChangedProtocol> {
     nnDVDoubleUISlider* minSpeed;
     nnDVBoolUISwitch* enablePing;
     nnDVBoolUISwitch* enableAutoStop;
     nnDVStringUIText* serverURL;
}


@property (nonatomic, retain) IBOutlet nnDVDoubleUISlider* minSpeed;
@property (nonatomic, retain) IBOutlet nnDVBoolUISwitch* enablePing;
@property (nonatomic, retain) IBOutlet nnDVBoolUISwitch* enableAutoStop;
@property (nonatomic, retain) IBOutlet nnDVStringUIText* serverURL;


@end
