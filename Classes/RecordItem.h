//
//  RecordItem.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CoreLocation.h>

@class Recording;

@interface RecordItem : NSManagedObject
{
}

@property (nonatomic, retain) NSNumber * altitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSDate * timestamp;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) Recording * recording;
@property (nonatomic, retain) NSNumber *speed;
@property (nonatomic, retain) NSNumber *gradient;
@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *accuracy;



-(CLLocationCoordinate2D)getCoord;

@end