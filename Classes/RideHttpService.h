//
//  RideHttpService.h
//  glogger
//
//  Created by Brice Tebbs on 8/19/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "nnHTTPService.h"
#import "Recording.h"
#import "Glogger.h"

@class RideHttpService;

@protocol RideHttpServiceDelegate
-(void)gotResponse: (NSObject*)response forService: (RideHttpService*)service withError: (NSError*) error;
@optional
-(void)uploadProgress: (double)pct;

@end

@interface RideHttpService : nnHTTPService {
    id <RideHttpServiceDelegate> ride_delegate;
    
    Recording* recordingObject;
    NSMutableArray *uploadSamples;
    NSInteger lastUploadIndex;
    NSString *segmentGuid;

}

@property (nonatomic, assign) id <RideHttpServiceDelegate> ride_delegate;


-(void)uploadRide: (Recording*)recording;
-(void)sendPing:(CLLocation*) pingInfo;

@end
