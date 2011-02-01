//
//  nnDVBoolUISwitch.h
//
//  A UI element for toggling a checkbox preference. Talks to the preference manager to initialize 
//  and save the results.
//
//  Created by Brice Tebbs on 8/16/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "nnDVStoreProtocol.h"

@class nnDVBoolUISwitch;
@protocol nnDVBoolUISwitchDelegate
-(void)valueUpdated: (nnDVBoolUISwitch*)preference newValue: (BOOL)value;
@end

@interface nnDVBoolUISwitch : UISwitch {

    NSString* preferenceName;
    id <nnDVStoreProtocol> handler;
    id <nnDVBoolUISwitchDelegate> pref_delegate;
}

@property (nonatomic, assign)  id <nnDVBoolUISwitchDelegate> pref_delegate;

-(void)setup: (NSString*)name withHandler: (id <nnDVStoreProtocol>) handler;

// Load the UI with the value
-(void)populate;

// Store the value in the preference Store
-(void)save;
@end
