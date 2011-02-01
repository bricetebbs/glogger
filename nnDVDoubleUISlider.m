//
//  nnDVDoubleUISlider.m
//  glogger
//
//  Created by Brice Tebbs on 1/30/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "nnDVDoubleUISlider.h"

@interface nnDVDoubleUISlider() 
@property (nonatomic, assign) id <nnDVStoreProtocol> handler;
@property (nonatomic, retain) NSString* preferenceName;
@end

@implementation nnDVDoubleUISlider;
@synthesize handler;
@synthesize pref_delegate;
@synthesize preferenceName;
@synthesize sliderTextLabel;
@synthesize labelScale;
@synthesize labelFormat;

- (void)dealloc {
    [preferenceName release];
    [sliderTextLabel release];
    [labelFormat release];
    [super dealloc];
}

-(void)updateTextFromSlider
{    
    double mph = self.labelScale * self.value;
    sliderTextLabel.text = [NSString stringWithFormat:self.labelFormat,mph];
}

-(void)sliderChanged:(UISlider *)slider
{
    [self updateTextFromSlider];
}

-(void)setup: (NSString*)name withHandler: (id <nnDVStoreProtocol>) hdnlr
{
    self.preferenceName = name;
    self.handler = hdnlr;
    // So that text label wil be updated
    [self addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
}


-(void)populate
{
    [self setValue: [handler doubleForKey: preferenceName]];
    [self updateTextFromSlider];
}

-(void)save
{
    if ([handler doubleForKey: preferenceName] != self.value)
    {
        [self.pref_delegate valueUpdated: self newValue: self.value];
        [handler setDouble: self.value forKey:preferenceName];
    }
}


@end
