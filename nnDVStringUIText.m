//
//  nnDVStringUIText.m
//  glogger
//
//  Created by Brice Tebbs on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import "nnDVStringUIText.h"
@interface nnDVStringUIText() 
@property (nonatomic, assign) id <nnDVStoreProtocol> handler;
@property (nonatomic, retain) NSString* preferenceName;
@end


@implementation nnDVStringUIText
@synthesize preferenceName;
@synthesize handler;
@synthesize pref_delegate;


- (void)dealloc {
    [preferenceName release];
    [super dealloc];
}



-(void)setup: (NSString*)name withHandler: (id <nnDVStoreProtocol>) hdnlr
{
    self.preferenceName = name;
    self.handler = hdnlr;
}

-(void)populate
{
    [self setText: [handler stringForKey: preferenceName]];
}

-(void)save
{
    if ([handler stringForKey: preferenceName] != self.text)
    {
        [self.pref_delegate valueUpdated: self newValue: self.text];
        [handler setString:  self.text forKey:preferenceName];
    }
}

@end
