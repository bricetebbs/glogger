//
//  Glogger.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "Glogger.h"

NSString* const PREF_NOTIFY_ENABLE = @"notifyenable";
NSString* const PREF_RANDOMIZE_TIMES =@"random";
NSString* const PREF_SHOW_LIST_ON_START =@"showList";
NSString* const PREF_NEXT_SAMPLE_TIME=@"nextSampleTime";



NSString* const PREF_USERNAME = @"username";
NSString* const PREF_PASSWORD = @"password";
NSString* const PREF_MIN_SPEED = @"minSpeed";
NSString* const PREF_PING_ENABLE = @"enablePing";
NSString* const PREF_AUTOSTOP_ENABLE = @"enableAutoStop";
NSString* const PREF_SERVER_URL_STRING =@"serverURL";


NSString* const APP_NAME=@"Glogger";

NSString* const SERVER_STRING = @"http://ride.northnitch.com";
//NSString* SERVER_STRING = @"http://192.168.1.126:8000";


NSString* const AUTHENTICATE_URL = @"sharider/app/authenticate/";
NSString* const UPLOAD_URL = @"sharider/upload/";
NSString* const PING_URL = @"sharider/ping/";
NSString* const MAP_URL_TEMPLATE = @"sharider/ride/map/%@";


NSString* const REQUEST_TAG_PING_AUTH = @"r_ping_auth";
NSString* const REQUEST_TAG_PING = @"r_ping";


NSString* const REQUEST_TAG_UPLOAD_AUTH = @"r_upload_auth";
NSString* const REQUEST_TAG_UPLOAD = @"r_upload";
NSString* const REQUEST_TAG_LAST_UPLOAD = @"r_last_upload";


NSString* const REQUEST_TAG_AUTH_TEST = @"r_auth";
