//
//  RideHttpService.m
//  glogger
//
//  Created by Brice Tebbs on 8/19/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "RideHttpService.h"
#import "ASIHTTPRequest.h"


#import "JSON.h"
#import "RecordItem.h"
#import "northNitch.h"

@interface RideHttpService ()

@property (nonatomic, retain) NSMutableArray *uploadSamples;
@property (nonatomic, retain) NSString* segmentGuid;
@property (nonatomic, retain) Recording* recordingObject;


-(void) processResponse:(NSObject*) response forRequest: (ASIHTTPRequest *)theRequest;

-(void)continueUploadingData;
@end

@implementation RideHttpService
@synthesize ride_delegate;
@synthesize uploadSamples;
@synthesize segmentGuid;
@synthesize recordingObject;

     
-(void)processResponse:(NSObject*)response forRequest: (ASIHTTPRequest*) theRequest
{
    [super processResponse: response forRequest: theRequest];
    
    NSString* command = [theRequest.userInfo objectForKey:@"command"];
    
    // Send the progress update if we need too.
    if ([command isEqualToString: REQUEST_TAG_UPLOAD] || [command isEqualToString: REQUEST_TAG_LAST_UPLOAD] ) {
        [ride_delegate uploadProgress:(float)lastUploadIndex/(float)[self.uploadSamples count] ];
    }
    
    // Send done unless this was a partial upload which only needs progress.
    if( ![command isEqualToString: REQUEST_TAG_UPLOAD])
    {
        [ride_delegate gotResponse: response forService: self withError: [theRequest error]];
    }
    else {
        [self continueUploadingData];
    }

}


#pragma mark -
#pragma mark Upload Stuff

-(void)continueUploadingData
{
    
    NSString* headers = @"LAT,LON,TIM,DST,ALT,GRD,SPD";
    
    NSString* samples = @"";
    
    NSInteger newLast = MIN(lastUploadIndex + 20, ([self.uploadSamples count] -1));
    
    NSInteger index;
    NSInteger maxIndex = 0;
    NSString* currentSegmentGuid = [[self.segmentGuid copy] autorelease];
    for (index = lastUploadIndex+1; index <= newLast; index++) {
        RecordItem* item = [self.uploadSamples objectAtIndex:index];
        
        if (  ([item.type integerValue] == kSampleStart) && (index > lastUploadIndex+1)) {
            // Send what we have and the next thing will be a new segment
            self.segmentGuid = makeUUID();
            break;
        }
        
        samples = [samples stringByAppendingFormat:@"%@, %@, %f, %@, %@, %@, %@,",item.latitude, item.longitude, [item.timestamp timeIntervalSince1970],
                   item.distance, item.altitude, item.gradient, item.speed];
        
        maxIndex = index;
    }
    
    
    
    NSString* tag = REQUEST_TAG_UPLOAD;
    
    
    lastUploadIndex = maxIndex;
    if (lastUploadIndex >= [self.uploadSamples count] -1)
    {
        tag = REQUEST_TAG_LAST_UPLOAD;
    }
    
    [self submitPostRequest:UPLOAD_URL withData: [NSDictionary dictionaryWithObjectsAndKeys:
                                                                  recordingObject.guid, @"ride_guid",
                                                                  currentSegmentGuid, @"segment_guid",
                                                                  headers, @"headers",
                                                                  samples, @"samples", 
                                                                  recordingObject.label, @"ride_name",
                                                                  nil]
                                     andTag: tag];
}


-(void)beginUploadingData
{
    lastUploadIndex = -1;
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];
    
    self.uploadSamples = [[NSMutableArray alloc] init];
    [self.uploadSamples addObjectsFromArray:[[recordingObject.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]]];
    
    self.segmentGuid = makeUUID();
    
    
    [self continueUploadingData];
    
   
}


-(void)uploadRide: (Recording*) recording
{
    
    self.recordingObject = recording;
    [self beginUploadingData];
}

#pragma mark -
#pragma mark Ping Stuff

-(void)sendPing:(CLLocation*) pingInfo
{
    double latitude = pingInfo.coordinate.latitude;
    double longitude = pingInfo.coordinate.longitude;
    double speed = pingInfo.speed;
    double heading = 0.0;
    
    
    
    [self submitPostRequest:PING_URL withData:[NSDictionary dictionaryWithObjectsAndKeys:
                                                               [NSNumber numberWithDouble: latitude],@"latitude",
                                                               [NSNumber numberWithDouble: longitude], @"longitude",
                                                               [NSNumber numberWithDouble: heading], @"heading",
                                                               [NSNumber numberWithDouble: speed], @"speed",
                                                               nil] 
                                     andTag: REQUEST_TAG_PING];
    
    
}

@end
