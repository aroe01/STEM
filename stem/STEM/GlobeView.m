//
//  GlobeView.m
//  Earth Mantra 2
//
//  Created by Ian on 6/4/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GlobeView.h"
#import "EarthShader.h"
#import "Updater.h"


@interface GlobeView ()

@property (nonatomic) BOOL globeInitialized;
@property (strong, nonatomic) WhirlyGlobeViewController *globeViewC;
@property (strong, nonatomic) MaplyBaseViewController *baseViewC;
@property (strong, nonatomic) CLLocation* initialLocation;

// MaplyActiveObject *updater;
// My Updater class derives from the MaplyActiveObject - Once instantiated the WhirlyGlob framework will call it at the beginning of each frame draw.
@property (strong, nonatomic) Updater *updater;
@property (strong, nonatomic) MaplyComponentObject *people;

@property (strong, nonatomic) GameSceneManager* gameSceneManager;

@end

@implementation GlobeView {
    
    MaplyCoordinate capitals[10];
    CGRect boundsSquare;

}

-(GlobeView*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager beginWithZoom:(BOOL)zoom {
    
    NSLog(@"gsGlobe initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame]) {
        //do initializations here.
        
        self.gameSceneManager = manager;
//        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
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
        
        self.gameSceneManager.locationManager.delegate = nil;
    }
}

- (void)initGlobeScene {
    
    self.globeInitialized = NO;
    
/*
    // Get location manager up and running and don't do anything else until the location of the user is identified
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    // Also added the 'NSLocationWhenInUseUsageDescription' row to the info.plist file; without it this code fails.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [self.locationManager startUpdatingLocation];
*/
    
    self.gameSceneManager.locationManager.delegate = self;
    
    CLLocation *location = self.gameSceneManager.locationManager.location;
    if(location) {
        
        self.globeInitialized = TRUE;
        [self initializeGlobeWithLocation:location];
    }
}

-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    NSLog(@"GSGlobe:updateBounds");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    //    NSLog(@"GSGlobe:didUpdateLocations");
    
    CLLocation* location = [locations lastObject];
    
    // Now that we have the user's location we can initiialize the globe.
    if(!self.globeInitialized) {
        
        self.globeInitialized = YES;
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
    
    
    
    self.initialLocation = location;
    // Create an empty globe and add it to the view
    
    self.globeViewC = [[WhirlyGlobeViewController alloc] init];
//    self.globeViewC.delegate = self;
    self.baseViewC = self.globeViewC;
    
    
    
    
    if(self.bounds.size.width > self.bounds.size.height) {
        boundsSquare.size.width = self.bounds.size.width;
        boundsSquare.size.height = self.bounds.size.width;
    } else {
        boundsSquare.size.width = self.bounds.size.height;
        boundsSquare.size.height = self.bounds.size.height;
    }
    boundsSquare.origin.x = 0;
    boundsSquare.origin.y = 0;
    self.baseViewC.view.frame = self.bounds = boundsSquare;
    
    
//    self.baseViewC.view.frame = self.bounds;
    
    [self addSubview:self.baseViewC.view];
    
    //    baseViewC.view.hidden = YES;
    
    self.globeViewC.clearColor = [UIColor clearColor];
    self.globeViewC.view.backgroundColor = [UIColor clearColor];
    
    // Set thirty fps if we can get it ­ change this to 3 if you find your app is struggling
    self.globeViewC.frameInterval = 2;
    
    
    //1.5
    float zoomHeight = 3.0;
    [self.globeViewC setPosition:MaplyCoordinateMakeWithDegrees(self.initialLocation.coordinate.longitude, self.initialLocation.coordinate.latitude) height:zoomHeight];
    [self.globeViewC setZoomLimitsMin:zoomHeight max:zoomHeight];
    
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
        
        layer.shaderProgramName = [EarthShader setupEarthShader:self.baseViewC];
        
        
        layer.handleEdges = (self.globeViewC != nil);
        layer.coverPoles = (self.globeViewC != nil);
        layer.requireElev = false;
        layer.waitLoad = false;
        layer.drawPriority = 0;
        layer.singleLevelLoading = false;
        
        [self.baseViewC addLayer:layer];
        
        self.globeInitialized = TRUE;
        
//        [self.globeViewC animateWithDelegate:self time:ZOOM_DURATION];
        
        
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
                 
                 layer.shaderProgramName = [EarthShader setupEarthShader:self.baseViewC];
                 
                 bool requireElev = false;
                 layer.requireElev = requireElev;
                 int maxLayerTiles = 256;
                 layer.maxTiles = maxLayerTiles;
                 
                 layer.handleEdges = (self.globeViewC != nil);
                 layer.coverPoles = (self.globeViewC != nil);
                 layer.requireElev = false;
                 layer.waitLoad = false;
                 layer.drawPriority = 0;
                 layer.singleLevelLoading = false;
                 [self.baseViewC addLayer:layer];
                 
                 
                 NSLog(@"**************** GSGlobe initialized ******************");
                 self.globeInitialized = TRUE;
                 
                 
                 
                 
                 // Start the zoom animation. GSGlobe implements the WhirlyGlobeViewControllerAnimationDelegate. Calling animateWithDelegate means
                 // the framework will call my delegate methods below each frame.
                 //             [globeViewC animateWithDelegate:self time:ZOOM_DURATION];
                 
                 
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
                 
                 if (!self.updater) {
                    [self addUpdater];
                 }
                 
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
    int numLocations = (sizeof(capitals) / sizeof(MaplyCoordinate));
    NSLog(@"number of locations -- %i\n", numLocations);
    NSLog(@"1st Entry %f\n", capitals[3].x);
    
    self.updater = [[Updater alloc] initWithPeriod:20.0 people:self.people locations:capitals numberOfLocations:numLocations viewC:self.globeViewC];
  
    [self.globeViewC addActiveObject:self.updater];
}

@end
