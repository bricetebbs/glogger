//
//  RecordItem.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "RecordItem.h"



@implementation RecordItem

@dynamic altitude;
@dynamic latitude;
@dynamic longitude;
@dynamic timestamp;
@dynamic type;
@dynamic recording;
@dynamic speed;
@dynamic gradient;
@dynamic distance;
@dynamic accuracy;

-(CLLocationCoordinate2D)getCoord
{
    CLLocationCoordinate2D rval;
    rval.latitude = [self.latitude doubleValue];
    rval.longitude = [self.longitude doubleValue];
    return rval;
}

@end
