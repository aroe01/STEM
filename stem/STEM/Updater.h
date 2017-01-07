//
//  Updater.h
//  Global Mantra
//
//  Created by Ian Foster on 4/4/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WhirlyGlobe/WhirlyGlobeComponent.h>

typedef struct EMUserStruct {
    uint ID;
    uint numUsersInSet;
    NSTimeInterval timeCreated;
    MaplyCoordinate location;
} EMUser;

@interface Updater : MaplyActiveObject

/// Initialize with period (amount of time for one orbit), radius and color of the sphere and a starting point
- (id)initWithPeriod:(float)period people:(MaplyComponentObject *)people locations:(MaplyCoordinate *)locations numberOfLocations:(int)count viewC:(MaplyBaseViewController *)viewC;

@end
