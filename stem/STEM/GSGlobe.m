//
//  GSGlobe.m
//  Earth 2
//
//  Created by Ian on 9/15/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "GSGlobe.h"
#import "EarthShader.h"
#import "Updater.h"
#import "GSShare.h"
#import "GSInfo.h"
#import "GSMainMenu.h"
#import "UIImage+Trim.h"

#include <math.h>



static const NSTimeInterval ZOOM_DURATION = 3;  //3
static const float Z00M_FROM = 10.0;
//static const float Z00M_CHANGE = -9.0;
static const float Z00M_CHANGE = -8.5;
static const float DELAY_BEFORE_Z00M_IN = 0.1;

@interface GSGlobe ()

@end

@implementation GSGlobe {

    //    WhirlyGlobeViewController *theViewC;
    UIView* theNebulaView;
    Boolean globeInitialized;
    Boolean globeInStartZoomPosition;
    
    WhirlyGlobeViewController *globeViewC;
    MaplyBaseViewController *baseViewC;
    CLLocation* initialLocation;
    
    NSTimeInterval zoomCurrentTime;
    NSTimeInterval zoomStartTime;
    NSTimeInterval zoomEndTime;
    
    WhirlyGlobeViewControllerAnimationState *theState;
    
//    MaplyActiveObject *updater;
    // My Updater class derives from the MaplyActiveObject - Once instantiated the WhirlyGlob framework will call it at the beginning of each frame draw.
    Updater *updater;
    MaplyCoordinate capitals[10];
    MaplyComponentObject *_people;
    
    UIImageView *bgImgView;
//    UIView *globeSnapShotView;

    UIView *globeContainerView;

//    UIImageView *loadingImageView;
    
    UIImage* testimg;
    
    int earthFormedTestCnt;
    
    CGRect boundsSquare;

    
}

-(GSGlobe*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"gsGlobe initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.

        bgImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"launch-screen-768x1024.png"]];
        bgImgView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:bgImgView];
        
        [self applyBGConstraints];
        
        earthFormedTestCnt = 0;
        
    }
    return self;
}

/*
 This method gets called when the view's superview changes, even when it's removed from it's superview.
 
 */
- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    // Initialize the scene only if it is being added to it's superview
    if(self.superview)
    {
        NSLog(@"GSGlobe didMoveToSuperview: Added to superview");
        [self initGlobeScene];
    } else {
        
        m_pManager.locationManager.delegate = nil;
    }
}

- (void)initGlobeScene {
    
    globeInitialized = FALSE;
    globeInStartZoomPosition = FALSE;

    m_pManager.locationManager.delegate = self;
    
    CLLocation *location = m_pManager.locationManager.location;
    if(location) {
        
        globeInitialized = TRUE;
        [self initializeGlobeWithLocation:location];
        NSLog(@"GSGlobe initGlobeScene: A location was there");
    }
    
    MyViewOrientation orientation;
    if(self.bounds.size.width > self.bounds.size.height) {
        orientation = MyViewOrientationLandscape;
    } else {
        orientation = MyViewOrientationPortrait;
    }
    
    CGFloat scale =  [UIScreen mainScreen].scale;
    [self setNebulaBackground:self.bounds.size orientation:orientation scale:scale];
    
}


-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    NSLog(@"GSGlobe:updateBounds");
    NSLog(@"Bounds Width = %f", self.bounds.size.width);
    NSLog(@"Bounds Height = %f", self.bounds.size.height);

    [self setNebulaBackground:size orientation:orientation scale:scale];

    self.bounds = boundsSquare;
}

-(void)setNebulaBackground:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    if(orientation == MyViewOrientationPortrait) {
        
        NSLog(@"setNebulaBackground:MyViewOrientationPortrait");
        if(scale == 2.f && size.height == 480 ) {       // Point size 480, Device size 960
            NSLog(@"iPhone 4s");
        } else if (scale == 2.f && size.height == 568 ) { // Point size 568, Device size 1136
            NSLog(@"iPhone 5, 5s, 6");
        } else if (scale == 2.f && size.height == 667) { // Point size 667, Device size 1334
            NSLog(@"iPhone 6");
        } else if (scale == 3.f && size.height == 736) { // Point size 736, Device size 2208
            NSLog(@"iPhone 6Plus / 6sPlus");
        } else if (scale == 1.f && size.height == 1024) { // Point size ???, Device size 1024
            NSLog(@"iPad 2");
        } else if (scale == 2.f && size.height == 1024) { // Point size ???, Device size 2048
            NSLog(@"iPad Retina / iPad Air / iPad Air 2");
        }
        
    } else {
        NSLog(@"setNebulaBackground:MyViewOrientationPortrait");
        if(scale == 2.f && size.height == 480 ) {       // Point size 480, Device size 960
            NSLog(@"iPhone 4s");
        } else if (scale == 2.f && size.height == 568 ) { // Point size 568, Device size 1136
            NSLog(@"iPhone 5, 5s, 6");
        } else if (scale == 2.f && size.height == 667) { // Point size 667, Device size 1334
            NSLog(@"iPhone 6");
        } else if (scale == 3.f && size.height == 736) { // Point size 736, Device size 2208
            NSLog(@"iPhone 6Plus / 6sPlus");
        } else if (scale == 1.f && size.height == 1024) { // Point size ???, Device size 1024
            NSLog(@"iPad 2");
        } else if (scale == 2.f && size.height == 1024) { // Point size ???, Device size 2048
            NSLog(@"iPad Retina / iPad Air / iPad Air 2");
        }
    }
/*
    NSLog(@"Scale = %f", scale);
    NSLog(@"Size = %f", size.height);
    NSLog(@"Current Scale = %f", globeViewC.currentMapScale);
    
    NSLog(@"Current Zoom = %f", [globeViewC currentMapZoom:MaplyCoordinateMakeWithDegrees(initialLocation.coordinate.longitude, initialLocation.coordinate.latitude)]);
*/
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
//    NSLog(@"GSGlobe:didUpdateLocations");
    
    CLLocation* location = [locations lastObject];
    
    // Now that we have the user's location we can initiialize the globe.
    if(!globeInitialized) {
        
        globeInitialized = TRUE;
        [self initializeGlobeWithLocation:location];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    NSString *errorType = (error.code == kCLErrorDenied) ?
    @"Access Denied" : @"Unknown Error X";
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error getting Location"
                          message:errorType
                          delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil];
    //    [alert show];
}

- (void)initializeGlobeWithLocation: (CLLocation*) location {
    NSLog(@"GSGlobe:initializeGlobeWithLocation");
    

    
    initialLocation = location;
    // Create an empty globe and add it to the view
    
    globeViewC = [[WhirlyGlobeViewController alloc] init];
    globeViewC.delegate = self;
    baseViewC = globeViewC;
    
    if(self.bounds.size.width > self.bounds.size.height) {
        boundsSquare.size.width = self.bounds.size.width;
        boundsSquare.size.height = self.bounds.size.width;
    } else {
        boundsSquare.size.width = self.bounds.size.height;
        boundsSquare.size.height = self.bounds.size.height;
    }
    boundsSquare.origin.x = 0;
    boundsSquare.origin.y = 0;
    baseViewC.view.frame = self.bounds = boundsSquare;
    
    globeContainerView = [[UIView alloc]initWithFrame:baseViewC.view.bounds];
    [self addSubview:globeContainerView];
    globeContainerView.hidden = YES;
    [globeContainerView addSubview:baseViewC.view];

    [(UIViewController*) m_pManager addChildViewController:baseViewC];
    
    globeViewC.clearColor = [UIColor clearColor];
    globeViewC.view.backgroundColor = [UIColor clearColor];
    
    // Set thirty fps if we can get it ­ change this to 3 if you find your app is struggling
    globeViewC.frameInterval = 2;
    
    [globeViewC setPosition:MaplyCoordinateMakeWithDegrees(initialLocation.coordinate.longitude, initialLocation.coordinate.latitude) height:3.0];
    
    // set up the data source
    // add the capability to use the local tiles or remote tiles
    NSString *jsonTileSpec = nil;
    NSString *thisCacheDir = nil;
    
    // we'll need this layer in a second
    MaplyQuadImageTilesLayer *layer;
    
    bool useLocalTiles = false;
    if (useLocalTiles)
    {
        MaplyMBTileSource *tileSource =
        [[MaplyMBTileSource alloc] initWithMBTiles:@"geography-class_medres"];
        
        layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys
                                                           tileSource:tileSource];
        
        layer.shaderProgramName = [EarthShader setupEarthShader:baseViewC];

        
        layer.handleEdges = (globeViewC != nil);
        layer.coverPoles = (globeViewC != nil);
        layer.requireElev = false;
        layer.waitLoad = false;
        layer.drawPriority = 0;
        layer.singleLevelLoading = false;
        
        [baseViewC addLayer:layer];
        
        globeInitialized = TRUE;
        
        [globeViewC animateWithDelegate:self time:ZOOM_DURATION];
        
        
        capitals[0] = MaplyCoordinateMakeWithDegrees(location.coordinate.longitude, location.coordinate.latitude);
        capitals[1] = MaplyCoordinateMakeWithDegrees(130.966667, 14.583333);
        capitals[2] = MaplyCoordinateMakeWithDegrees(55.75, 37.616667);
        capitals[3] = MaplyCoordinateMakeWithDegrees(-0.1275, 51.507222);
        capitals[4] = MaplyCoordinateMakeWithDegrees(-66.916667, 10.5);
        capitals[5] = MaplyCoordinateMakeWithDegrees(139.6917, 35.689506);
        capitals[6] = MaplyCoordinateMakeWithDegrees(166.666667, -77.85);
        capitals[7] = MaplyCoordinateMakeWithDegrees(-58.383333, -34.6);
        capitals[8] = MaplyCoordinateMakeWithDegrees(-74.075833, 4.598056);
        capitals[9] = MaplyCoordinateMakeWithDegrees(-79.516667, 8.983333);
        
        
//        globeViewC.height = 1.5;
//        [globeViewC setPosition:MaplyCoordinateMakeWithDegrees(initialLocation.coordinate.longitude, initialLocation.coordinate.latitude) height:1.5];
        
        
    } else {
        
        // For network paging layers, where we'll store temp files
        NSString *cacheDir = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)  objectAtIndex:0];
//        jsonTileSpec = @"https://api.tiles.mapbox.com/v4/iangf.eac6e79e.json?access_token=pk.eyJ1IjoiaWFuZ2YiLCJhIjoiTVlpSmI3NCJ9.FBsZhDdn60M3FpPs9VQ4SA";
//        jsonTileSpec = @"https://api.tiles.mapbox.com/v4/mapbox.dark.json?access_token=pk.eyJ1IjoiaWFuZ2YiLCJhIjoiTVlpSmI3NCJ9.FBsZhDdn60M3FpPs9VQ4SA";
        jsonTileSpec = @"https://api.tiles.mapbox.com/v4/iangf.da15466e.json?access_token=pk.eyJ1IjoiaWFuZ2YiLCJhIjoiTVlpSmI3NCJ9.FBsZhDdn60M3FpPs9VQ4SA";
        thisCacheDir = [NSString stringWithFormat:@"%@/mbtilesregular1/",cacheDir];
        //        thisCacheDir = [NSString stringWithFormat:@"%@/mbtilessat1/",cacheDir];
        // thisCacheDir = [NSString stringWithFormat:@"%@/mbtilesterrain1/",cacheDir];
        
        if (jsonTileSpec)
        {
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:jsonTileSpec]];
            
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            operation.responseSerializer = [AFJSONResponseSerializer serializer];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
             {
                 // Add a quad earth paging layer based on the tile spec we just fetched
                 MaplyRemoteTileSource *tileSource = [[MaplyRemoteTileSource alloc] initWithTilespec:responseObject];
                 tileSource.cacheDir = thisCacheDir;
                 
                 int zoomLimit = 0;
                 
                 if (zoomLimit != 0 && zoomLimit < tileSource.maxZoom)
                     tileSource.tileInfo.maxZoom = zoomLimit;
                 MaplyQuadImageTilesLayer *layer = [[MaplyQuadImageTilesLayer alloc] initWithCoordSystem:tileSource.coordSys tileSource:tileSource];
                 layer.handleEdges = true;
                 //                 layer.waitLoad = imageWaitLoad;
                 
                 layer.shaderProgramName = [EarthShader setupEarthShader:baseViewC];
                 
                 bool requireElev = false;
                 layer.requireElev = requireElev;
                 int maxLayerTiles = 256;
                 layer.maxTiles = maxLayerTiles;
                 
                 layer.handleEdges = (globeViewC != nil);
                 layer.coverPoles = (globeViewC != nil);
                 layer.requireElev = false;
                 layer.waitLoad = false;
//                 layer.waitLoad = YES;
                 
                 
                 layer.drawPriority = 0;
                 layer.singleLevelLoading = false;
                 [baseViewC addLayer:layer];
                 
                 
                 NSLog(@"**************** GSGlobe initialized ******************");
                 globeInitialized = TRUE;



                 
                 // Start the zoom animation. GSGlobe implements the WhirlyGlobeViewControllerAnimationDelegate. Calling animateWithDelegate means
                 // the framework will call my delegate methods below each frame.
//                 [globeViewC animateWithDelegate:self time:ZOOM_DURATION];
                 
                 
                 capitals[0] = MaplyCoordinateMakeWithDegrees(location.coordinate.longitude, location.coordinate.latitude);
                 capitals[1] = MaplyCoordinateMakeWithDegrees(130.966667, 14.583333);
                 capitals[2] = MaplyCoordinateMakeWithDegrees(55.75, 37.616667);
                 capitals[3] = MaplyCoordinateMakeWithDegrees(-0.1275, 51.507222);
                 capitals[4] = MaplyCoordinateMakeWithDegrees(-66.916667, 10.5);
                 capitals[5] = MaplyCoordinateMakeWithDegrees(139.6917, 35.689506);
                 capitals[6] = MaplyCoordinateMakeWithDegrees(166.666667, -77.85);
                 capitals[7] = MaplyCoordinateMakeWithDegrees(-58.383333, -34.6);
                 capitals[8] = MaplyCoordinateMakeWithDegrees(-74.075833, 4.598056);
                 capitals[9] = MaplyCoordinateMakeWithDegrees(-79.516667, 8.983333);
                 
//                 [globeViewC setPosition:MaplyCoordinateMakeWithDegrees(initialLocation.coordinate.longitude, initialLocation.coordinate.latitude) height:1.5];

                 if (!updater) {
//                     [self addUpdater];
                     
//                     [NSTimer scheduledTimerWithTimeInterval:DELAY_BEFORE_Z00M_IN target:self selector:@selector(beginGlobeZoomInAnimation) userInfo:nil repeats:NO];
                     
                     [self beginGlobeZoomWhenErathFormed];
                 }
                 



                 
                 
                 
                 
                 //                 [globeViewC setZoomLimitsMin:20.5 max:30.5];
                 /*
                  float min = 0;
                  float max = 0;
                  [globeViewC getZoomLimitsMin:&min max:&max];
                  NSLog(@"t %+.6f\n", min);
                  NSLog(@"t %+.6f\n", max);
                  */
#ifdef RELOADTEST
                 [self performSelector:@selector(reloadLayer:) withObject:nil afterDelay:10.0];
#endif
             }
                                             failure:^(AFHTTPRequestOperation *operation, NSError *error)
             {
                 NSLog(@"Failed to reach JSON tile spec at: %@",jsonTileSpec);
             }
             ];
            
            [operation start];
        }
        
    }
    
    
    
}

- (void)beginGlobeZoomWhenErathFormed {
 
    // Escape this loop if it's enacted more than 50 times
    if(earthFormedTestCnt > 50) {
        [self beginGlobeZoomInAnimation];
    } else {
        
        UIImage *originalImage = baseViewC.snapshot;
        UIImage *semiTransparentCrop = [originalImage imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
        if([self hasEarthFormed: semiTransparentCrop] == NO) {
            earthFormedTestCnt++;
            [NSTimer scheduledTimerWithTimeInterval:DELAY_BEFORE_Z00M_IN target:self selector:@selector(beginGlobeZoomWhenErathFormed) userInfo:nil repeats:NO];
        } else {
            [self beginGlobeZoomInAnimation];
        }
    }
}

- (void)beginGlobeZoomInAnimation {
    NSLog(@"gsGlobe addGlobeView");
    
    // Obtain a snapshot image of the 3D globe at it's current height, set the snapshot's scale to zero, add it to the view and then animate the snapshot's scale to create a zoom in affect. Note that at this point the 3D globe is hidden from view because I have it in a container view that has it's hidden property set to YES. If the hidden property of the 3D globe's view was set to YES, I wouldn't be able to take a snapshot of it, hence the use of a parent contianer.
    UIImage *originalImage = baseViewC.snapshot;
    UIImage *semiTransparentCrop = [originalImage imageByTrimmingTransparentPixelsRequiringFullOpacity:NO];
    m_pManager.globeSnapShotView = [[UIImageView alloc] initWithImage:semiTransparentCrop];
    m_pManager.globeSnapShotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.0, 0.0);
    m_pManager.globeSnapShotView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:m_pManager.globeSnapShotView];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    

    
    
//    m_pManager.globeSnapShotView2 = [baseViewC.view resizableSnapshotViewFromRect:baseViewC.view.bounds afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];

    m_pManager.globeSnapShotView2 = [[UIImageView alloc] initWithImage:semiTransparentCrop];
    
    
    
    
    
//    [loadingImageView removeFromSuperview];

    // Create a zoom effect by Animating the smapshot image's scale transform.
    [UIView animateWithDuration:1.0
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         m_pManager.globeSnapShotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0);
                     }
                     completion:^(BOOL finished){


                         // Remove the 3D globe from the temporary container view and add it the main view.
                         [baseViewC.view removeFromSuperview];
                         baseViewC.view.translatesAutoresizingMaskIntoConstraints = NO;
                         [self addSubview:baseViewC.view];
                         
                         [self addConstraint:[NSLayoutConstraint constraintWithItem:baseViewC.view
                                                                          attribute:NSLayoutAttributeCenterX
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeCenterX
                                                                         multiplier:1.0
                                                                           constant:0.0]];
                         
                         [self addConstraint:[NSLayoutConstraint constraintWithItem:baseViewC.view
                                                                          attribute:NSLayoutAttributeCenterY
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeCenterY
                                                                         multiplier:1.0
                                                                           constant:0.0]];
                         
                         [self addConstraint:[NSLayoutConstraint constraintWithItem:baseViewC.view
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1.0
                                                                           constant:0.0]];
                         
                         [self addConstraint:[NSLayoutConstraint constraintWithItem:baseViewC.view
                                                                          attribute:NSLayoutAttributeWidth
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:self
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1.0
                                                                           constant:0.0]];
                         
                         
                         
                         
                         [globeContainerView removeFromSuperview];
                         [m_pManager.globeSnapShotView removeFromSuperview];
                         
                         // Start showing the users on the globe
                         if (!updater) {
                             [self addUpdater];
                         }
                     }];
    
}


/**
 * Structure to keep one pixel in RRRRRRRRGGGGGGGGBBBBBBBBAAAAAAAA format
 */

struct pixel {
    unsigned char r, g, b, a;
};

/**
 * Determine if the earth is fully formed.
 */

- (BOOL) hasEarthFormed: (UIImage*) image
{
    NSUInteger numberOfTransparentPixels = 0;
    
    // Allocate a buffer big enough to hold all the pixels
    struct pixel* pixels = (struct pixel*) calloc(1, image.size.width * image.size.height * sizeof(struct pixel));
    if (pixels != nil)
    {
        // Create a new bitmap
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGContextRef context = CGBitmapContextCreate(
                                                     (void*) pixels,
                                                     image.size.width,
                                                     image.size.height,
                                                     8,
                                                     image.size.width * 4,
                                                     colorSpace,
                                                     kCGImageAlphaPremultipliedLast
                                                     );
        
        if (context != NULL)
        {
            // Draw the image in the bitmap
            CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), image.CGImage);
            
            // Now that we have the image drawn in our own buffer, we can loop over the pixels to
            // process it. This simple case simply counts all pixels that have a pure red component.
            
            // There are probably more efficient and interesting ways to do this. But the important
            // part is that the pixels buffer can be read directly.
            
            NSUInteger numberOfPixels = image.size.width * image.size.height;
            
            while (numberOfPixels > 0) {
                
                if (pixels->a < 255) {
                    numberOfTransparentPixels++;
                }
                pixels++;
                numberOfPixels--;
            }
            
            CGContextRelease(context);
            CGColorSpaceRelease(colorSpace);
        }
        
//        free(pixels);
    }
    
    float areaOfCircle = M_PI * pow((image.size.width / 2), 2.0);
    float areaOfRect = pow(image.size.width, 2.0);
    float actualAreaOfCircle = areaOfRect - numberOfTransparentPixels;
    
    
    float pd = ((fabsf(areaOfCircle - actualAreaOfCircle) / ((areaOfCircle + actualAreaOfCircle)/2))*100);
    NSLog(@"###### PERCENTAGE DIFFERENCE %f", pd);
    
    if(pd > 1.9) {
        return NO;
    } else {
        return YES;
    }
    
}
    
// Here I'm using the WhirlyGlobeControllerAnimationDelegate to make the globe zoom in
- (void)globeViewController:(WhirlyGlobeViewController *)viewC startState:(WhirlyGlobeViewControllerAnimationState *)startState startTime:(NSTimeInterval)startTime endTime:(NSTimeInterval)endTime {
    
    theState = [[WhirlyGlobeViewControllerAnimationState alloc] init];
    
    zoomStartTime = startTime;
    zoomEndTime = endTime;
    NSLog(@"End Time %+.6f\n", endTime);
}

- (WhirlyGlobeViewControllerAnimationState *)globeViewController:(WhirlyGlobeViewController *)viewC stateForTime:(NSTimeInterval)currentTime {
    
    //    NSLog(@"t %+.6f\n", currentTime);
    zoomCurrentTime = currentTime - zoomStartTime;
//    NSLog(@"zoomCurrentTime %+.6f\n", zoomCurrentTime);

    theState.pos = MaplyCoordinateMakeWithDegrees(initialLocation.coordinate.longitude, initialLocation.coordinate.latitude);
    
    float _newHeight = [self tween:zoomCurrentTime from: Z00M_FROM change: Z00M_CHANGE duration: ZOOM_DURATION ];
    theState.height = _newHeight;
//    NSLog(@"_newHeight %+.6f\n", _newHeight);
    
    if(currentTime >= zoomEndTime) {
        NSLog(@"End Zoom %+.6f\n", currentTime);
        
        if (!updater) {
            [self addUpdater];
        }
    }
    
    return theState;
}

- (float)tween:(float)t from:(float)b change:(float)c duration:(float)d {
    return c * t / d + b;
}



- (void) update:(double)delta {
//        NSLog(@"GSGlobe update");
    
}

- (void) render {
    //    NSLog(@"GSGlobe render");
    [self setNeedsDisplay]; //this sets up a deferred call to drawRect.
}

- (void)drawRect:(CGRect)rect {
    //    NSLog(@"GSGlobe drawRect");
    
    //    [self showFPS];
}

- (void)addUpdater
{
    //    updater = [[Updater alloc] initWithPeriod:20.0 radius:0.01 color:[UIColor orangeColor] viewC:globeViewC];

    
    int numLocations = (sizeof(capitals) / sizeof(MaplyCoordinate));
    NSLog(@"number of locations -- %i\n", numLocations);
    NSLog(@"1st Entry %f\n", capitals[3].x);
    
    updater = [[Updater alloc] initWithPeriod:20.0 people:_people locations:capitals numberOfLocations:numLocations viewC:globeViewC];
    
    [globeViewC addActiveObject:updater];
}

/*
- (void)addPeople {
    
    // get the image and create the markers
    UIImage *icon = [UIImage imageNamed:@"mind.png"];
    //    UIImage *icon = [UIImage animatedImageNamed:@"minda" duration:1.0];
    
    UIColor *color = [UIColor colorWithRed:1.00 green:0.00 blue:0.00 alpha:1.0];
    UIColor *color2 = [UIColor colorWithRed:0.00 green:0.00 blue:1.00 alpha:1.0];
    
    UIImage *img = [self imageWithColor: color2];
    
    NSMutableArray *markers = [NSMutableArray array];
    
    bool useScreenMarkers = false;
    if(useScreenMarkers) {
        
        for (unsigned int ii=0;ii<10;ii++)
        {
            MaplyScreenMarker *marker = [[MaplyScreenMarker alloc] init];
            //        marker.image = icon;
            if(ii == 0) {
                //            marker.color = color2;
                marker.image = icon;
                marker.size = CGSizeMake(40,40);
            } else {
                marker.color = color;
                marker.size = CGSizeMake(4,4);
            }
            marker.loc = capitals[ii];
            [markers addObject:marker];
        }
        // add them all at once (for efficency)
        
        _people = [globeViewC addScreenMarkers:markers desc:nil];
        
    } else {
        
        for (unsigned int ii=0;ii<10;ii++)
        {
            MaplyMarker *marker = [[MaplyMarker alloc] init];
            if(ii == 0) {
                marker.image = icon;
                marker.size = CGSizeMake(.1,.1);
            } else {
                marker.image = img;
                marker.size = CGSizeMake(.05,.05);
            }
            marker.loc = capitals[ii];
            [markers addObject:marker];
        }
        // add them all at once (for efficency)
        _people = [globeViewC addMarkers:markers desc:nil];
    }
}
*/

- (UIImage *)imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

/*
 * The following delegate method is called by the WhirlyGlobeViewController when the user selects an WhirlyGlobe screen object. To obtain the notification
 * this view controller has had to fill in the WhirlyGlobeViewControllerDelegate.
 * On obtaining a notification this code calls the method handleSelection().
 *
 * See http://mousebird.github.io/WhirlyGlobe/tutorial/vector_selection.html and http://mousebird.github.io/WhirlyGlobe/tutorial/screen_marker_selection.html
 *
 */
- (void) globeViewController:(WhirlyGlobeViewController *)viewC
                   didSelect:(NSObject *)selectedObj
{
    NSLog(@"Something Selected!");
    [self handleSelection:viewC selected:selectedObj];
}

/**
 * This code is called by our delegate above when a screen object is selected. Here we are only interested when the user clicks on
 * their brain which is a MaplyMarker. On clicking on their brain we remove the globe view and show the scroll view.
 *
 */
- (void) handleSelection:(MaplyBaseViewController *)viewC selected:(NSObject *)selectedObj
{
    // Ensure it's a MaplyMarker object
    if ([selectedObj isKindOfClass:[MaplyMarker class]])
    {
        NSLog(@" In Selection Handle 2!");
//        [m_pManager doSceneChange:[GSShare class]];
        
        
        // If this is the first time that the app has been launched then go to the info screen (mission statement screen), otherwise go to the main menu
        if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"]){
            [m_pManager doSceneChange:[GSInfo class]];
        } else {
         
            [m_pManager doSceneChange:[GSMainMenu class]];
        }
    }
}

- (void)applyBGConstraints {
    
    // -------------------------
    
//    [self removeConstraints:self.constraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bgImgView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bgImgView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bgImgView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bgImgView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0]];

}

@end
