//
//  nnDVStringUIText.h
//  glogger
//
//  Created by Brice Tebbs on 1/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "nnDVStoreProtocol.h"

@class nnDVStringUIText;
@protocol nnDVStringUITextDelegate
-(void)valueUpdated: (nnDVStringUIText*)preference newValue: (NSString*)value;
@end

@interface nnDVStringUIText : UITextField {
    NSString* preferenceName;
    id <nnDVStoreProtocol> handler;
    id <nnDVStringUITextDelegate> pref_delegate;
}

@property (nonatomic, assign)  id <nnDVStringUITextDelegate> pref_delegate;

-(void)setup: (NSString*)name withHandler: (id <nnDVStoreProtocol>) handler;

// Load the UI with the value
-(void)populate;

// Store the value in the preference Store
-(void)save;
@end


