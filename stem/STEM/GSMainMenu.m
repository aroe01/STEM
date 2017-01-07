//
//  GSMainMenu.m
//  Earth Mantra 2
//
//  Created by Ian on 9/12/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GSMainMenu.h"
#import "GSGlobe.h"
#import "GSInfo.h"
#import "GSMantra.h"
#import "GSShare.h"
#import "GSAlarm.h"
#import "GSGraph.h"
#import "GSNews.h"


@implementation GSMainMenu {
    
    UIButton *btnShare;
    UIButton *btnNews;
    UIButton *btnEarth;
    UIButton *btnGraph;
    UIButton *btnAlarm;
    
    UIImageView *bg;

    UILabel *lblLogo;
}

-(GSMainMenu*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"GSMainMenu initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        bg =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-compressed.png"]];
        bg.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:bg];
        
        [self diplayLogo];
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
        NSLog(@"GSMainMenu didMoveToSuperview: Added to superview");
        
        [self initializeButtons];
        
        MyViewOrientation orientation;
        if(self.bounds.size.width > self.bounds.size.height) {
            orientation = MyViewOrientationLandscape;
        } else {
            orientation = MyViewOrientationPortrait;
        }
        
        CGFloat scale =  [UIScreen mainScreen].scale;
        [self updateBounds:self.bounds.size orientation:orientation scale:scale];
        
        
    } else {
        
        NSLog(@"GSMainMenu didMoveToSuperview: Removed from superview");
        
        [self removeConstraints:self.constraints];
        [btnShare removeFromSuperview];
        [btnNews removeFromSuperview];
        [btnEarth removeFromSuperview];
        [btnAlarm removeFromSuperview];
        [btnGraph removeFromSuperview];
        
    }
}

-(void)initializeButtons {
    NSLog(@"--------initializeButtons");
    
    btnShare = [self createButtonWithImageName: @"btn_share.png" andID:@"share"];
//    btnShare.adjustsImageWhenHighlighted = YES;
    btnShare.showsTouchWhenHighlighted = YES;
    [btnShare setImage:[UIImage imageNamed: @"btn_share_glow.png"] forState:UIControlStateHighlighted];
    [self addSubview: btnShare];
    
    btnNews = [self createButtonWithImageName: @"btn_news.png" andID:@"news"];
    btnNews.showsTouchWhenHighlighted = YES;
    [btnNews setImage:[UIImage imageNamed: @"btn_news_glow.png"] forState:UIControlStateHighlighted];
    [self addSubview: btnNews];
    
    btnEarth = [self createButtonWithImageName: @"btn_earth.png" andID:@"earth"];
    btnEarth.showsTouchWhenHighlighted = YES;
    [btnEarth setImage:[UIImage imageNamed: @"btn_earth_glow.png"] forState:UIControlStateHighlighted];
    [self addSubview: btnEarth];
    
    btnGraph = [self createButtonWithImageName: @"btn_graph.png" andID:@"graph"];
    btnGraph.showsTouchWhenHighlighted = YES;
    [btnGraph setImage:[UIImage imageNamed: @"btn_graph_glow.png"] forState:UIControlStateHighlighted];
    [self addSubview: btnGraph];
    
    btnAlarm = [self createButtonWithImageName: @"btn_alarm.png" andID:@"alarm"];
    btnAlarm.showsTouchWhenHighlighted = YES;
    [btnAlarm setImage:[UIImage imageNamed: @"btn_alarm_glow.png"] forState:UIControlStateHighlighted];
    [self addSubview: btnAlarm];
    
    [ self setConstraints];
}

-(UIButton* )createButtonWithImageName:(NSString *)imageName andID:(NSString *)ID{
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage* img = [UIImage imageNamed: imageName];
    [btn setBackgroundImage: img forState: UIControlStateNormal];
    [btn setTitle:ID forState: UIControlStateNormal];
    [btn setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
    
    // Add an action in current code file (i.e. target)
    [btn addTarget:self action:@selector(buttonPressed:)
  forControlEvents:UIControlEventTouchUpInside];
    
    // Tell iOS not to automatically create constraints for this btn.
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    return btn;
}

- (void)buttonPressed:(UIButton *)button {
    NSLog(@"Button Pressed: %@", button.currentTitle);
    
    NSString *btnTitle = [NSString stringWithString:button.currentTitle];
    if([btnTitle isEqualToString:@"alarm"]){
        [m_pManager doSceneChange:[GSAlarm class]];
        
    } else if([btnTitle isEqualToString:@"share"]) {
        [m_pManager doSceneChange:[GSShare class]];
        
    } else if([btnTitle isEqualToString:@"earth"]) {
        [m_pManager doSceneChange:[GSGlobe class]];
        
    } else if([btnTitle isEqualToString:@"news"]) {
        [m_pManager doSceneChange:[GSNews class]];
        
    } else if([btnTitle isEqualToString:@"graph"]) {
        [m_pManager doSceneChange:[GSGraph class]];
    }
    
}

- (void)setConstraints {
    
    int heightOffset = 50;
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.5
                                                      constant:heightOffset]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnNews
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.5
                                                      constant:heightOffset]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnNews
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:0.5
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnNews
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnNews
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    

    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnEarth
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.5
                                                      constant:heightOffset]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnEarth
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.5
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnEarth
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnEarth
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    

    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnGraph
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:heightOffset]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnGraph
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:0.5
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnGraph
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnGraph
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1
                                                      constant:heightOffset]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.5
                                                      constant:0]];
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.33
                                                      constant:0]];
    
    
    // -------------------------
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bg
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bg
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bg
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:bg
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.5
                                                      constant:0.0]];
    
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lblLogo
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:50]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lblLogo
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    
}

- (void)diplayLogo {
    
    lblLogo = [[UILabel alloc] initWithFrame:CGRectZero];
    lblLogo.text = @"S T E M";
    lblLogo.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 45.0];
    lblLogo.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    [lblLogo sizeToFit];
    [self addSubview: lblLogo];
    lblLogo.translatesAutoresizingMaskIntoConstraints = NO;
}

@end
