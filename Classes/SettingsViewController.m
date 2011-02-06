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

@synthesize enablePing;
@synthesize enableAutoStop;
@synthesize serverURL;
@synthesize minSpeed;

-(void)dealloc
{
    [enablePing release];
    [enableAutoStop release];
    [serverURL release];
    [minSpeed release];
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


// Overridden from superclass
-(void)testLogin
{
    [super testLogin];
    
    nnHTTPService* service = [[nnHTTPService alloc] initWithServerString: serverURL.text];
    service.delegate = self;
    
    [service checkAuthenticationCredentials: AUTHENTICATE_URL username: username.text password:password.text];
}

-(void)setupPreferences:(id<nnDVStoreProtocol>)pm usernameKey:(NSString *)user passwordKey:(NSString *)pass
{
    [super setupPreferences: pm usernameKey:user passwordKey:pass];
    
    self.enablePing.dvInfo = [[[nnDVBool alloc] init: PREF_PING_ENABLE withHandler: preferenceManager] autorelease];
    self.enableAutoStop.dvInfo = [[[nnDVBool alloc] init: PREF_AUTOSTOP_ENABLE withHandler: preferenceManager] autorelease];
    self.serverURL.dvInfo = [[[nnDVString alloc] init: PREF_SERVER_URL_STRING withHandler: preferenceManager] autorelease];
    self.minSpeed.dvInfo = [[[nnDVDouble alloc] init: PREF_MIN_SPEED withHandler: preferenceManager] autorelease];
    
    self.enableAutoStop.dvInfo.dvHoldUpdates = YES;
    self.enablePing.dvInfo.dvHoldUpdates = YES;
    self.serverURL.dvInfo.dvHoldUpdates = YES;
    self.minSpeed.dvInfo.dvHoldUpdates = YES;
    
    self.minSpeed.minimumValue = MIN_MIN_SPEED;
    self.minSpeed.maximumValue = MAX_MIN_SPEED;
    self.minSpeed.labelScale = 2.23693629;
    self.minSpeed.labelFormat = @"%4.2fMph";
    
    self.enablePing.dvInfo.dvChangedDelegate = self;
}


- (void)viewDidLoad {

    [super viewDidLoad];
    
    gloggerAppDelegate *adel = (gloggerAppDelegate*)[UIApplication sharedApplication].delegate;
    
    [self setupPreferences: adel.preferenceManager usernameKey: PREF_USERNAME passwordKey: PREF_PASSWORD];

}


-(void)valueUpdated: (nnDVBase*) element
{
    if ([element matchesTag: PREF_PING_ENABLE])
    {
        BOOL value = [element getBool];
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
