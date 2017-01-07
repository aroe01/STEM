//
//  gsTest.h
//  Earth 1
//
//  Created by Ian on 9/15/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "GameScene.h"
#import <WhirlyGlobeComponent.h>
#import <CoreLocation/CoreLocation.h>
#import "AFHTTPRequestOperation.h"



@interface GSGlobe : GameScene <CLLocationManagerDelegate,WhirlyGlobeViewControllerDelegate, WhirlyGlobeViewControllerAnimationDelegate>

- (void)didMoveToSuperview;

//@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *startPoint;
@property (assign, nonatomic) CLLocationDistance distanceFromStart;


@end
