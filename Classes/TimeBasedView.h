//
//  TimeBasedView.h
//  metime
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "nnScrollingCGView.h"
#import "RecordItem.h"
#import "Glogger.h"


@protocol TimeBasedViewDelegateProtocol
-(void)newItem: (RecordItem*)event;
@end


enum ChartFlags {
    kShowElevation = 0x0001,
    kShowGradient = 0x0002,
    kShowSpeed = 0x0004,
};

@interface TimeBasedView : nnScrollingCGView {
    NSMutableArray* items;
    
    double firstTime, lastTime;
    double minAltitude, maxAltitude;
    double minSpeed, maxSpeed;
    double totalDistance;

    
    id <TimeBasedViewDelegateProtocol> newitem_delegate;
    
    NSInteger showFlags;

    
    CGAffineTransform speedTransform;
    CGAffineTransform altitudeTransform;
    CGAffineTransform gradientTransform;
    
    NSInteger vMargin;;
    NSInteger vSize;    
    
}

@property (nonatomic, assign) NSInteger showFlags;

@property (nonatomic, assign)  id <TimeBasedViewDelegateProtocol> newitem_delegate;
-(void)setupTimeBasedView;
-(void)updateCurrentItem;
-(void)setItems:(NSArray *)ilist;
@end
