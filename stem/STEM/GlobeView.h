//
//  GlobeView.h
//  Earth Mantra 2
//
//  Created by Ian on 6/4/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <WhirlyGlobe/MaplyComponent.h>
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPRequestOperation.h"
#import "GameSceneManager.h"


@interface GlobeView : UIView <CLLocationManagerDelegate> {
     
}

- (void)didMoveToSuperview;
-(id) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager beginWithZoom:(BOOL)zoom;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startPoint;
@property (assign, nonatomic) CLLocationDistance distanceFromStart;


@end
