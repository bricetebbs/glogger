//
//  RecordingMapViewController.h
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Recording.h"
#import "RecordItem.h"
#import "TimeBasedView.h"
#import "nnImageToggleButton.h"
#import "nnCoreDataManager.h"

@interface RecordingMapViewController : UIViewController <MKMapViewDelegate,
                        nnImageToggleButtonDelegate,
                        TimeBasedViewDelegateProtocol> 
{
    MKMapView* mapView;
    Recording *recordingObject;
    nnCoreDataManager *coreDataManager;
    id <MKOverlay> trackOverlay;
    id <MKAnnotation> spotAnnotation;
    
    IBOutlet TimeBasedView* graphView;
    IBOutlet nnImageToggleButton* elevation_toggle;
    IBOutlet nnImageToggleButton* gradient_toggle;
    IBOutlet nnImageToggleButton* speed_toggle;
                            
    IBOutlet UILabel *timeLabel;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *speedLabel;
    IBOutlet UILabel *elevationLabel;
    IBOutlet UILabel *gradientLabel;
    
    NSArray *items;
}



@property (nonatomic, retain) IBOutlet MKMapView* mapView;
@property (nonatomic, retain) Recording *recordingObject;
@property (nonatomic, retain) nnCoreDataManager *coreDataManager;
@property (nonatomic, retain) NSArray *items;


@end
