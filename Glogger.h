//
//  Glogger.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


NSString* PREF_NOTIFY_ENABLE; 
NSString* PREF_RANDOMIZE_TIMES;
NSString* PREF_NEXT_SAMPLE_TIME;
NSString* PREF_SHOW_LIST_ON_START;


NSString* PREF_SPREADSHEET_WORKSHEET_FEED;
NSString* PREF_SPREADSHEET_TABLE_FEED;
NSString* PREF_TABLE_RECORD_FEED;
NSString* PREF_DOCLIST_UPLOAD_FEED;


NSString* DEFAULT_WORKSHEET_NAME;
NSString* DEFAULT_SPREADSHEET_NAME;
NSString* DEFAULT_TABLE_NAME;

NSString* PREF_USERNAME;
NSString* PREF_PASSWORD;
NSString* PREF_MIN_SPEED;
NSString* PREF_PING_ENABLE;
NSString* PREF_AUTOSTOP_ENABLE;
NSString* PREF_SERVER_URL_STRING;


NSString* APP_NAME;


NSString* SERVER_STRING;
NSString* AUTHENTICATE_URL;
NSString* UPLOAD_URL;
NSString* PING_URL;
NSString* MAP_URL_TEMPLATE;


NSString* REQUEST_TAG_PING_AUTH;
NSString* REQUEST_TAG_PING;

NSString* REQUEST_TAG_UPLOAD_AUTH;
NSString* REQUEST_TAG_UPLOAD;
NSString* REQUEST_TAG_LAST_UPLOAD;

NSString* REQUEST_TAG_AUTH_TEST;


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


