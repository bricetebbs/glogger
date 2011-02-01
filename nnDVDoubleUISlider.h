//
//  nnDVDoubleUISlider.h
//  glogger
//
//  Created by Brice Tebbs on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "nnDVStoreProtocol.h"


@class nnDVDoubleUISlider;
@protocol nnDVDoubleUISliderDelegate
-(void)valueUpdated: (nnDVDoubleUISlider*)preference newValue: (double)value;
@end

@interface nnDVDoubleUISlider : UISlider {
    NSString* preferenceName;
    id <nnDVStoreProtocol> handler;
    id <nnDVDoubleUISliderDelegate> pref_delegate;
    UILabel *sliderTextLabel;
    
    NSString *labelFormat;
    double labelScale;
}

-(void)setup: (NSString*)name withHandler: (id <nnDVStoreProtocol>) handler;

@property (nonatomic, assign)  id <nnDVDoubleUISliderDelegate> pref_delegate;
@property (nonatomic, retain) IBOutlet UILabel *sliderTextLabel;
@property (nonatomic, retain) NSString *labelFormat;
@property (nonatomic, assign) double labelScale;

// Load the UI with the value
-(void)populate;

// Store the value in the preference Store
-(void)save;
@end
