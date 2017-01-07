//
//  gsIntro.m
//  Earth 1
//
//  Created by Ian on 9/14/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "GSIntro.h"
#import "GSGlobe.h"
//#import "GSInfo.h"
#import "GSMantra.h"
#import "GSTest.h"

@interface GSIntro ()

@end

@implementation GSIntro {
    
    UIView *storyboard;
}

-(GSIntro*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"gsIntro initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        storyboard =   [[[NSBundle mainBundle] loadNibNamed:@"OtherLaunchScreen" owner:self options:nil] firstObject];
        storyboard.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:storyboard];
        
        [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(performSceneChange) userInfo:nil repeats:NO];
        [self initConstraints];
        
/*
        for (NSString *familyName in [UIFont familyNames]){
            NSLog(@"Family name: %@", familyName);
            for (NSString *fontName in [UIFont fontNamesForFamilyName:familyName]) {
                NSLog(@"--Font name: %@", fontName);
            }
        }
*/
        
    }
    return self;
}


- (void)performSceneChange {
    NSLog(@"gsIntro testSceneChange");
    [m_pManager doSceneChange:[GSGlobe class]];
}

- (void) update:(double)delta {
//    NSLog(@"gsIntro update");
}

- (void) render {
//    NSLog(@"gsIntro render");
    [self setNeedsDisplay]; //this sets up a deferred call to drawRect.
}

- (void)drawRect:(CGRect)rect {
//    NSLog(@"gsIntro drawRect");

//    [self showFPS];
}


- (void)initConstraints {
    
    // -------------------------
    
    [self removeConstraints:self.constraints];


    [self addConstraint:[NSLayoutConstraint constraintWithItem:storyboard
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:storyboard
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:storyboard
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:storyboard
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];

}
@end
