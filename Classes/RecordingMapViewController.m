//
//  RecordingMapViewController.m
//  glogger
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "RecordingMapViewController.h"
#import "Recording.h"
#import "RecordItem.h"
#import "northNitch.h"



@implementation RecordingMapViewController

@synthesize recordingObject;
@synthesize coreDataManager;
@synthesize mapView;
@synthesize items;

- (void)dealloc {
    [items release];
    [recordingObject release];
    [coreDataManager release];
    [mapView release];
    [timeLabel release];
    [elevationLabel release];
    [speedLabel release];
    [gradientLabel release];
    [graphView release];
    [elevation_toggle release];
    [gradient_toggle release];
    [speed_toggle release];
    [super dealloc];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = @"Map";
    self.mapView.delegate = self;
    graphView.newitem_delegate =self;
    elevation_toggle.delegate = self;
    gradient_toggle.delegate = self;
    speed_toggle.delegate = self;
    [graphView setupTimeBasedView];
    
    graphView.showFlags = kShowElevation;
    elevation_toggle.highlighted = YES;
}


- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id <MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[MKPolyline class]])
    {
        MKPolylineView*    aView = [[[MKPolylineView alloc] initWithPolyline:(MKPolyline*) overlay] autorelease];
        
        aView.fillColor = [[UIColor cyanColor] colorWithAlphaComponent:0.2];
        aView.strokeColor = [[UIColor blueColor] colorWithAlphaComponent:0.7];
        aView.lineWidth = 3;
        return aView;
    }
    
    return nil;
}


-(void)newItem:(RecordItem *)event
{
    if (!spotAnnotation) {
       // [self.mapView removeAnnotation: spotAnnotation];
        
        spotAnnotation = [[MKPointAnnotation alloc] init];
        
        [ self.mapView addAnnotation: spotAnnotation];
        [spotAnnotation release];
    }

    CLLocationCoordinate2D coord;
    
    coord.latitude = [event.latitude doubleValue];
    coord.longitude = [event.longitude doubleValue];
    spotAnnotation.coordinate = coord;
    
    self.mapView.centerCoordinate = coord;
    
    RecordItem* firstEvent = [self.items objectAtIndex:0];
    
    NSTimeInterval timeElapsed = [event.timestamp timeIntervalSinceDate:firstEvent.timestamp];
    NSInteger hours = timeElapsed/3600.0;
    timeElapsed = timeElapsed - hours * 3600;
    NSInteger mins = timeElapsed/60.0;
    timeElapsed = timeElapsed - mins* 60;
    NSInteger secs = timeElapsed;
    timeLabel.text = [NSString stringWithFormat:@"%02d:%02d:%02d",hours,mins,secs];
    distanceLabel.text = [NSString stringWithFormat:@"%6.3fmi",[event.distance doubleValue] * 0.000621371192];
    gradientLabel.text = [NSString stringWithFormat:@"%5.2f%%",[event.gradient doubleValue]];
    speedLabel.text = [NSString stringWithFormat:@"%5.2fmph",[event.speed doubleValue] * 2.23693629];
    elevationLabel.text = [NSString stringWithFormat:@"%dft",(int)([event.altitude doubleValue] * 3.2808399)];
}


-(void)stateUpdated:(nnImageToggleButton *)indicator isNow:(BOOL)state
{
    NSInteger mask = 0;
    if(indicator == elevation_toggle)
    {
        mask = kShowElevation;
    }
    else if(indicator == speed_toggle)
    {
        mask = kShowSpeed;
    }
    else if(indicator == gradient_toggle)
    {
        mask = kShowGradient;
    }
    
    if (state) {
        graphView.showFlags |= mask;
    }
    else {
        graphView.showFlags &= ~mask;
    }
    nnDebugLog(@"Mask:%d state:%d   Flags now %d", mask, state, graphView.showFlags);
    [graphView setNeedsDisplay];
}

-(void)buildMapDisplay
{
    if(trackOverlay)
    {
        [self.mapView removeOverlay: trackOverlay];
    }
    
    CLLocationCoordinate2D* points = (CLLocationCoordinate2D*)malloc(sizeof(CLLocationCoordinate2D)*[self.items count]);
    CLLocationCoordinate2D* pp = points;
    for (RecordItem* ritem in self.items)
    {
        *pp++ = [ritem getCoord];
    }
    
    MKPolyline* polyLine = [MKPolyline polylineWithCoordinates:points count: [self.items count]];
    polyLine.title = @"Path";
    
    [self.mapView addOverlay: polyLine];
    
    trackOverlay = polyLine;
    
    MKCoordinateRegion reg = MKCoordinateRegionMakeWithDistance(points[0], 1000, 1000);
    self.mapView.region = reg;
    
    free(points);

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.title = @"Map";
    
    NSSortDescriptor *timeSort = [NSSortDescriptor sortDescriptorWithKey:@"timestamp" ascending:YES];

    self.items = [[self.recordingObject.samples allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:timeSort]];
    
    [self buildMapDisplay];

    
    [graphView setItems: self.items];
    [graphView updateCurrentItem];

}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




@end
