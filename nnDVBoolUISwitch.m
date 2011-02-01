//
//  nnDVBoolUISwitch.m

//
//  Created by Brice Tebbs on 8/16/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "nnDVBoolUISwitch.h"
@interface nnDVBoolUISwitch () 
@property (nonatomic, assign) id <nnDVStoreProtocol> handler;
@property (nonatomic, retain) NSString* preferenceName;
@end


@implementation nnDVBoolUISwitch
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
    [self setOn: [handler boolForKey: preferenceName]];
}

-(void)save
{
    if ([handler boolForKey: preferenceName] != self.on)
    {
        [self.pref_delegate valueUpdated: self newValue: self.on];
        [handler setBool: self.on forKey:preferenceName];
    }
}


@end
