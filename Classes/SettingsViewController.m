//
//  SettingsViewController.m
//  glogger
//
//  Created by Brice Tebbs on 8/13/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "SettingsViewController.h"

#import "Glogger.h"
#import "gloggerAppDelegate.h"
@implementation SettingsViewController

double MIN_MIN_SPEED = 0;
double MAX_MIN_SPEED = 4.4704;


-(void)dealloc
{
    [super dealloc];
}

-(void)serviceResponse: (NSObject*)response forTag: (NSString*)tag withError: (NSError*) error;
{
    @try {
        [self showAuthTestResult: [response valueForKey:@"response"]];
    }
    @catch (NSException * e) 
    {
        [self showAuthTestResult: @"Error"];
    }
}


// Override this in subclass
-(void)testLogin
{
    [super testLogin];
    
    nnHTTPService* service = [[nnHTTPService alloc] initWithServerString: serverURL.text];
    service.delegate = self;
    
    [service checkAuthenticationCredentials: AUTHENTICATE_URL username: username.text password:password.text];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [enablePing setup: PREF_PING_ENABLE withHandler:preferenceManager];
    [enableAutoStop setup: PREF_AUTOSTOP_ENABLE withHandler: preferenceManager];
    [serverURL setup: PREF_SERVER_URL_STRING withHandler: preferenceManager];
    [minSpeed setup: PREF_MIN_SPEED withHandler: preferenceManager];
    
    minSpeed.minimumValue = MIN_MIN_SPEED;
    minSpeed.maximumValue = MAX_MIN_SPEED;
    minSpeed.labelScale = 2.23693629;
    minSpeed.labelFormat = @"%4.2fMph";
    
    enablePing.pref_delegate = self;
}


-(void)valueUpdated: (nnDVBoolUISwitch*)preference newValue: (BOOL)value
{
    if(preference == enablePing)
    {
        gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
        
        if (value == YES) 
        {
            [adel.recordingManager startPinging];
        }
        else 
        {
            [adel.recordingManager stopPinging];
        }
    }
}


-(void)storeSettings
{
    [enablePing save];
    [enableAutoStop save];
    [serverURL save];
    [minSpeed save];
    [super storeSettings];
}

-(void)populateSettings
{
    [enablePing populate];
    [enableAutoStop populate];
    [serverURL populate];
    [minSpeed populate];
    [super populateSettings];
}


@end
