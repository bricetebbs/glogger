//
//  TimeBasedView.m
//  metime
//
//  Created by Brice Tebbs on 7/28/10.
//  Copyright 2010 northNitch Studios, Inc. All rights reserved.
//

#import "TimeBasedView.h"
#import "RecordItem.h"
#import <math.h>
#import "northNitch.h"



NSInteger FULL_MAP_SIZE=2000;
NSInteger INSET_PIXELS = 170;

@implementation TimeBasedView
@synthesize newitem_delegate;
@synthesize showFlags;



-(void)moveToStart
{
    
    CGPoint p = CGPointMake(-INSET_PIXELS,0);    
    [self setContentOffset: p animated: NO];
}


-(void)setupTimeBasedView
{
    UIEdgeInsets insets;
    
    [self setupScollingCGViewWithMapSize: CGRectMake(0,0, FULL_MAP_SIZE, self.bounds.size.height)];

    
    insets.top = insets.bottom = 0;
    insets.left = insets.right = INSET_PIXELS;
    
    self.contentInset = insets;
    
    [self setScrollZoomOptions: nnkZoomHorizontal | nnkScrollingHorizontal];
    
    [self setZoomMin:(self.bounds.size.width/FULL_MAP_SIZE) andMax:(self.bounds.size.width/FULL_MAP_SIZE * 100.0)];
    
    [self fitView];
    [self moveToStart];
    
}


- (void)dealloc {
    [items dealloc];
    [super dealloc];
}



-(void)setItems:(NSArray *)ilist
{
    if(!items)
        items = [[NSMutableArray alloc] init];
    else {
        [items removeAllObjects];
    }
    
    [items addObjectsFromArray: ilist];
    
    if ([ilist count] > 0) {
        RecordItem* first =[ilist objectAtIndex:0];
        firstTime = [first.timestamp timeIntervalSince1970];
        
        RecordItem* last =[ilist objectAtIndex:[ilist count] -1];
        lastTime = [last.timestamp timeIntervalSince1970];
        totalDistance = [last.distance doubleValue];
   }
    
    minAltitude = MAXFLOAT;
    maxAltitude = -MAXFLOAT;
    
    minSpeed = MAXFLOAT;
    maxSpeed = -MAXFLOAT;

    // THis really needs to be stored
   for (RecordItem* i in items)
   {
       double a = [i.altitude doubleValue];
       minAltitude = MIN(minAltitude,a);
       maxAltitude = MAX(maxAltitude,a);
       
       double s = [i.speed doubleValue];
       minSpeed = MIN(minSpeed,s);
       maxSpeed = MAX(maxSpeed,s);
       
   }
    
    
    // We need to compute the world to map matrices for the different series
    // FLip The map upside down
    CGAffineTransform w2mx = CGAffineTransformMake(FULL_MAP_SIZE/totalDistance, 0, 0, -self.bounds.size.height, 0, self.bounds.size.height );

    
    CGAffineTransform t = CGAffineTransformMakeTranslation(0.0, 12.0);
    CGAffineTransform s = CGAffineTransformMakeScale(1.0, 1.0/24.0);
    gradientTransform = CGAffineTransformConcat(t, s);
    gradientTransform = CGAffineTransformConcat(gradientTransform, w2mx);
    
    t = CGAffineTransformMakeTranslation(0.0, -minAltitude);
    s = CGAffineTransformMakeScale(1.0, 1.0/(maxAltitude - minAltitude));
    altitudeTransform = CGAffineTransformConcat(t, s);
    altitudeTransform = CGAffineTransformConcat(altitudeTransform, w2mx);

    
    t = CGAffineTransformMakeTranslation(0.0, -minSpeed);
    s = CGAffineTransformMakeScale(1.0, 1.0/(maxSpeed- minSpeed));
    speedTransform = CGAffineTransformConcat(t, s);
    speedTransform = CGAffineTransformConcat(speedTransform, w2mx);
    
}


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}


-(void)drawLegend: (CGContextRef) context
{
    
    CGContextSaveGState(context);

    CGAffineTransform xform = CGAffineTransformMake(1, 0, 0, -1, 0, 0);
    CGContextSetTextMatrix (context, xform);

    CGContextSelectFont (context,  "Helvetica-Bold", 10, kCGEncodingMacRoman);
    CGContextSetCharacterSpacing (context, 0);
    CGContextSetTextDrawingMode (context, kCGTextFill);
    CGContextSetRGBFillColor (context, 0,0, 0, 1.0); 
    
    NSString* string = [NSString stringWithFormat:@"%5.2f",zoomScale];
    const char *b =[string cStringUsingEncoding:NSMacOSRomanStringEncoding];
    CGContextShowTextAtPoint (context, 30, 10, b, strlen(b)); 

    
    CGContextSetRGBStrokeColor (context, 0,0,1.0, 1.0); 
    
    CGContextMoveToPoint(context, 0.5*self.bounds.size.width, 0.0);
    CGContextAddLineToPoint(context, 0.5*self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
    
    CGContextSetRGBStrokeColor(context, 1.0, 0.0, 0.0, 1.0);
    
       // Really should just make this its own list in setItems.
    for (RecordItem *e in items)
    {
       if([e.type integerValue] == kSampleStart)
       {
           
           CGPoint pt = CGPointMake([e.distance doubleValue], 0.0);
           
           pt = CGPointApplyAffineTransform(pt, worldToViewTransform);
           
           CGContextMoveToPoint(context, pt.x-3, 0);
           CGContextAddLineToPoint(context, pt.x, self.bounds.size.height/16.0);
           CGContextAddLineToPoint(context, pt.x+3, 0);
           CGContextStrokePath(context);
       }
    }
    CGContextRestoreGState(context);
    
    
    
}


-(void)drawSeries:(CGContextRef) context name: (NSString*)attribute
{
    
    CGContextSaveGState(context);
    
    CGFloat metersPerPixel = viewToWorldTransform.a;  // This gives us the scale from pixels To distance in meters
    
    double lastXpos = -metersPerPixel; // So the item gets picked in the IF below
        
    for (RecordItem *e in items)
    {
        double xPos = [e.distance doubleValue];
        
        if ((xPos - lastXpos) >= metersPerPixel ) 
        {
            CGPoint pt = CGPointMake( xPos, [[e valueForKey: attribute] doubleValue]);

            CGPoint scrPt = CGPointApplyAffineTransform(pt, worldToViewTransform);
            
            if(lastXpos < 0.0)
                CGContextMoveToPoint(context, scrPt.x, scrPt.y);
            else
                CGContextAddLineToPoint(context, scrPt.x, scrPt.y);
            
            lastXpos = pt.x;
        }
    }
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}


- (void)drawRect:(CGRect)rect {
    

    CGContextRef context = UIGraphicsGetCurrentContext();
    
    
    // Compensate for the scrolling we have done.
    CGContextTranslateCTM(context, scrollOffset.x, scrollOffset.y);
    
    
    CGContextSaveGState(context);
    
    
    CGContextSetLineWidth(context, 3.0);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    
    if(showFlags & kShowGradient)
    {
        CGContextSetRGBStrokeColor(context, 0.0, 1.0, 0.0, 1.0);
        [self updateWorldToMap: gradientTransform];
        [self drawSeries:context name:@"gradient"];
    }
    
    if(showFlags & kShowElevation)
    {
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 0.0, 1.0);
        [self updateWorldToMap: altitudeTransform];
        [self drawSeries:context name:@"altitude"];
    }
    
    if(showFlags & kShowSpeed)
    {
        CGContextSetRGBStrokeColor(context, 0.0, 0.0, 1.0, 1.0);
        [self updateWorldToMap:speedTransform];
        [self drawSeries:context name:@"speed"];
    }

    CGContextRestoreGState(context);
    
    
    CGAffineTransform w2mx = CGAffineTransformMake(FULL_MAP_SIZE/totalDistance, 0, 0, 1.0, 0, 0);
    
    [self updateWorldToMap: w2mx];
    
    
    [self drawLegend: context];
}


-(void)updateCurrentItem
{
    
    RecordItem *found = nil;
    double closestDist = totalDistance;
    
    CGPoint centerView = CGPointMake(self.bounds.size.width * 0.5, self.bounds.size.height * 0.5);
    CGPoint worldPosOfCenter = CGPointApplyAffineTransform(centerView, viewToWorldTransform);
    double sDist= worldPosOfCenter.x;
    
    // Could make a static c-array of doubles if needed for performance here.
    for (RecordItem *e in items)
    {
        double eDist = [e.distance doubleValue];  // cache this?
        double delta = sDist - eDist;
        if(delta >= 0.0)
        {
            closestDist = delta;
            found = e;
        }
        else
        {
            if(-delta < closestDist)
            {
                found = e;
            }
            break;
        }
    }
    if(found)
        [self.newitem_delegate newItem: found];
}

- (void)scrollViewDidScroll:(UIScrollView *)sv
{
    [super scrollViewDidScroll: sv];
    [self updateCurrentItem];
}

- (void)scrollViewDidZoom:(UIScrollView *)sv
{
    [super scrollViewDidZoom: sv];
    [self updateCurrentItem];
}


@end
