//
//  Glogger.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "Glogger.h"

NSString* PREF_NOTIFY_ENABLE = @"notifyenable";
NSString* PREF_RANDOMIZE_TIMES =@"random";
NSString* PREF_SHOW_LIST_ON_START =@"showList";
NSString* PREF_NEXT_SAMPLE_TIME=@"nextSampleTime";


NSString* PREF_SPREADSHEET_WORKSHEET_FEED = @"spreadsheetWorksheetFeed";
NSString* PREF_SPREADSHEET_TABLE_FEED =  @"spreadsheetTableFeed";
NSString* PREF_TABLE_RECORD_FEED = @"tableRecordFeed";
NSString* PREF_DOCLIST_UPLOAD_FEED = @"docListUploadFeed";

NSString* PREF_USERNAME = @"username";
NSString* PREF_PASSWORD = @"password";
NSString* PREF_MIN_SPEED = @"minSpeed";
NSString* PREF_PING_ENABLE = @"enablePing";
NSString* PREF_AUTOSTOP_ENABLE = @"enableAutoStop";
NSString* PREF_SERVER_URL_STRING =@"serverURL";


NSString* DEFAULT_TABLE_NAME=@"LOGTABLE";
NSString* DEFAULT_WORKSHEET_NAME=@"Sheet 1";
NSString* DEFAULT_SPREADSHEET_NAME=@"LogSheet";

NSString* APP_NAME=@"Glogger";

NSString* SERVER_STRING = @"http://ride.northnitch.com";
//NSString* SERVER_STRING = @"http://192.168.1.126:8000";


NSString* AUTHENTICATE_URL = @"sharider/app/authenticate/";
NSString* UPLOAD_URL = @"sharider/upload/";
NSString* PING_URL = @"sharider/ping/";
NSString* MAP_URL_TEMPLATE = @"sharider/ride/map/%@";


NSString* REQUEST_TAG_PING_AUTH = @"r_ping_auth";
NSString* REQUEST_TAG_PING = @"r_ping";


NSString* REQUEST_TAG_UPLOAD_AUTH = @"r_upload_auth";
NSString* REQUEST_TAG_UPLOAD = @"r_upload";
NSString* REQUEST_TAG_LAST_UPLOAD = @"r_last_upload";


NSString* REQUEST_TAG_AUTH_TEST = @"r_auth";
