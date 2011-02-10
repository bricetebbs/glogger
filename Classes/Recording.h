//
//  Recording.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "nnCoreDataTableViewController.h"

@interface Recording : NSManagedObject <nnCoreDataTableViewItemProtocol>
{
}

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSString * timezone;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSSet* samples;

@property (nonatomic, retain) NSNumber * distance_total;
@property (nonatomic, retain) NSNumber * elevation_max;
@property (nonatomic, retain) NSNumber * elevation_min;
@property (nonatomic, retain) NSNumber * gradient_max;
@property (nonatomic, retain) NSNumber * gradient_min;
@property (nonatomic, retain) NSNumber * points_filtered;
@property (nonatomic, retain) NSNumber * speed_avg;
@property (nonatomic, retain) NSNumber * speed_max;
@property (nonatomic, retain) NSNumber * speed_min;
@property (nonatomic, retain) NSNumber * stats_computed;
@property (nonatomic, retain) NSDate * time_max;
@property (nonatomic, retain) NSDate * time_min;





- (void)addSamplesObject:(NSManagedObject *)value;
- (void)removeSamplesObject:(NSManagedObject *)value;
- (void)addSamples:(NSSet *)value;
- (void)removeSamples:(NSSet *)value;

@end
