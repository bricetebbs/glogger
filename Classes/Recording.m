//
//  Recording.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "Recording.h"


// coalesce these into one @interface Recording (CoreDataGeneratedPrimitiveAccessors) section
@interface Recording (CoreDataGeneratedPrimitiveAccessors)

- (NSMutableSet*)primitiveSamples;
- (void)setPrimitiveSamples:(NSMutableSet*)value;

@end


@implementation Recording
@dynamic date;
@dynamic label;
@dynamic timezone;
@dynamic type;
@dynamic samples;
@dynamic distance_total;
@dynamic elevation_max;
@dynamic elevation_min;
@dynamic gradient_max;
@dynamic gradient_min;
@dynamic points_filtered;
@dynamic speed_avg;
@dynamic speed_max;
@dynamic speed_min;
@dynamic stats_computed;
@dynamic time_max;
@dynamic time_min;
@dynamic guid;


/*
 *
 * You do not need any of these.  
 * These are templates for writing custom functions that override the default CoreData functionality.
 * You should delete all the methods that you do not customize.
 * Optimized versions will be provided dynamically by the framework.
 *
 *
 */

- (void)addSamplesObject:(NSManagedObject *)value 
{    
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"samples" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    [[self primitiveSamples] addObject:value];
    [self didChangeValueForKey:@"samples" withSetMutation:NSKeyValueUnionSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)removeSamplesObject:(NSManagedObject *)value 
{
    NSSet *changedObjects = [[NSSet alloc] initWithObjects:&value count:1];
    
    [self willChangeValueForKey:@"samples" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    [[self primitiveSamples] removeObject:value];
    [self didChangeValueForKey:@"samples" withSetMutation:NSKeyValueMinusSetMutation usingObjects:changedObjects];
    
    [changedObjects release];
}

- (void)addSamples:(NSSet *)value 
{    
    [self willChangeValueForKey:@"samples" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
    [[self primitiveSamples] unionSet:value];
    [self didChangeValueForKey:@"samples" withSetMutation:NSKeyValueUnionSetMutation usingObjects:value];
}

- (void)removeSamples:(NSSet *)value 
{
    [self willChangeValueForKey:@"samples" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
    [[self primitiveSamples] minusSet:value];
    [self didChangeValueForKey:@"samples" withSetMutation:NSKeyValueMinusSetMutation usingObjects:value];
}




@end

