//
//  Glogger.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString* const PREF_NOTIFY_ENABLE; 
extern NSString* const PREF_RANDOMIZE_TIMES;
extern NSString* const PREF_NEXT_SAMPLE_TIME;
extern NSString* const PREF_SHOW_LIST_ON_START;



extern NSString* const PREF_USERNAME;
extern NSString* const PREF_PASSWORD;
extern NSString* const PREF_MIN_SPEED;
extern NSString* const PREF_PING_ENABLE;
extern NSString* const PREF_AUTOSTOP_ENABLE;
extern NSString* const PREF_SERVER_URL_STRING;


extern NSString* const APP_NAME;


extern NSString* const SERVER_STRING;
extern NSString* const AUTHENTICATE_URL;
extern NSString* const UPLOAD_URL;
extern NSString* const PING_URL;
extern NSString* const MAP_URL_TEMPLATE;


extern NSString* const REQUEST_TAG_PING_AUTH;
extern NSString* const REQUEST_TAG_PING;

extern NSString* const REQUEST_TAG_UPLOAD_AUTH;
extern NSString* const REQUEST_TAG_UPLOAD;
extern NSString* const REQUEST_TAG_LAST_UPLOAD;

extern NSString* const REQUEST_TAG_AUTH_TEST;


#define LOG_TO_GDOC 1
#define PUSH_FROM_LOCATION_CHANGE 1
#define PUSH_FROM_UPDATE_COMPLETE 1

#define MIN_START_SAMPLES 3
#define MIN_STOP_SAMPLES 3


enum {
    kRecordStatusRunning = 2,
    kRecordStatusStandby = 1,
    kRecordStatusStopped = 0,
};

enum {
    
    kGPSStatusGood =2,
    kGPSStatusOK = 1,
    kGPSStatusPoor =0,
};


enum {
    
    kSampleNormal =0,
    kSampleStart = 1,
};


