//
//  GSTest.m
//  Earth Mantra 2
//
//  Created by Ian on 6/4/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GSTest.h"
#import "GlobeView.h"

@interface GSTest ()

@end

@implementation GSTest {
    
    UIImageView *logo;
    GlobeView *globeView;
}

-(GSTest*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"GSTest initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        self.backgroundColor = [UIColor redColor];
        
        globeView = [[GlobeView alloc] initWithFrame:frame gameSceneManager:manager beginWithZoom:YES];
        [self addSubview: globeView];
        
    }
    return self;
}

@end

