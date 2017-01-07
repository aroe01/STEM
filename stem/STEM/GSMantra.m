//
//  GSMantra.m
//  Earth Mantra 2
//
//  Created by Ian on 3/22/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GSMantra.h"
#import "GSShare.h"
#import "GlobeView.h"


#import "BGTouchDownGestureRecognizer.h"
#import "BGAnimatingButton.h"
#import "ARAudioRecognizer.h"

#import <SceneKit/SceneKit.h>


@implementation GSMantra {
    
    //    UITapGestureRecognizer* tapGestureRecognizer;
    BGTouchDownGestureRecognizer* touchDownGestureRecognizer;
    
    BOOL _autoScroll;
    NSTimer *_nsTimer;
    
//    UIButton *btnShare;
  //  UIButton *btnAlarm;
    ARAudioRecognizer *audioRecognizer;
    
//    SCNView *globeView;
//    SCNNode *globeNode;
    float breatheScale;
    BOOL breatheOut;
    BOOL breathe;
    UILabel *lblBreathe;
    UILabel *lblStatus;
    UILabel *lblStatus2;
    
    float globeDegrees;
    
    GlobeView *otherGlobeView;
    UIImageView *globeHaloView1;
    UIImageView *globeHaloView2;

    CGRect boundsSquare;

    
    UIView *globeContainerView;
    
    int globeWidth;
    
}

-(GSMantra*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"GSMantra initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        [self addSubview: manager.webViewMantra];
        manager.webViewMantra.translatesAutoresizingMaskIntoConstraints = NO;
        
        breatheScale = 1.0;
        breatheOut = false;
        breathe = true;
        
        globeDegrees = 0;
        
        // Get the actual width of the globe - Only the snapshots have this since they are cropped to the globe's rectangle
        globeWidth = m_pManager.globeSnapShotView.bounds.size.width;
        
        m_pManager.webViewMantra.scrollView.scrollEnabled = NO; // i.f
        
    
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
        NSLog(@"GSMantra didMoveToSuperview: Added to superview");
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.webViewMantra
                                                         attribute:NSLayoutAttributeWidth
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeWidth
                                                        multiplier:1
                                                          constant:0]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.webViewMantra
                                                         attribute:NSLayoutAttributeHeight
                                                         relatedBy:NSLayoutRelationEqual
                                                            toItem:self
                                                         attribute:NSLayoutAttributeHeight
                                                        multiplier:1
                                                          constant:0]];
        
        
        // Create your custom TouchDownGestureRecognizer: http://stackoverflow.com/questions/15628133/uitapgesturerecognizer-make-it-work-on-touch-down-not-touch-up
        touchDownGestureRecognizer = [[BGTouchDownGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleTouchDown:)];
        
        touchDownGestureRecognizer.cancelsTouchesInView = NO;
        touchDownGestureRecognizer.delegate = self;
        [self addGestureRecognizer:touchDownGestureRecognizer];
        
        m_pManager.webViewMantra.scrollView.backgroundColor = [UIColor whiteColor];
        
        m_pManager.webViewMantra.delegate = self;
        m_pManager.webViewMantra.scrollView.delegate = self;
        
        audioRecognizer = [[ARAudioRecognizer alloc] init];
        audioRecognizer.delegate = self;
        
        [self initSnapshotGlobesAndHalos];
        [self showBreathText];
        [self showStatusText];
        
        
        MyViewOrientation orientation;
        if(self.bounds.size.width > self.bounds.size.height) {
            orientation = MyViewOrientationLandscape;
        } else {
            orientation = MyViewOrientationPortrait;
        }
        
        CGFloat scale =  [UIScreen mainScreen].scale;
        [self updateBounds:self.bounds.size orientation:orientation scale:scale];
        
        
        
        
        
        //////
        
        //[self beginAutoScroll];
        //m_pManager.webViewMantra.scrollView.scrollEnabled = YES;

        /////
        
        
        
    } else {
        
        NSLog(@"GSMantra didMoveToSuperview: Removed from superview");
        
        [self removeConstraints:self.constraints];
        [m_pManager.webViewMantra removeConstraints:m_pManager.webViewMantra.constraints];
        
    }
}


-(void)webView:(UIWebView *) webView didFailLoadWithError:(NSError *)error {
    NSLog(@"GSMantra:webView didFailLoadWithError");
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"GSMantra:webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"--------GSMantra webViewDidFinishLoad");
}


/*
 - (void)updateConstraints
 {
 [super updateConstraints];
 
 CGRect contentRect = CGRectZero;
 for (UIView *view in m_pManager.webView.scrollView.subviews) {
 contentRect = CGRectUnion(contentRect, view.frame);
 int i = 0;
 }
 }
 */

- (void)layoutSubviews {
    NSLog(@"GSMantra:layoutSubviews");
    
    [super layoutSubviews];
    //    CGFloat contentHeight = m_pManager.webView.scrollView.contentSize.height;
    //    NSLog(@"--------contentHeight %+.6f\n", contentHeight);
    
    // Use JS to obtain the content height, because m_pManager.webView.scrollView.contentSize.height, doesn't have the correct size
    // when layoutSubviews is first called
    NSString *height = [m_pManager.webViewMantra stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"**HEIGHT:%d", [height intValue]);
    
}

/**
 * Uncomment this method to see the "Red" subview lay out correctly
 */

/*
 + (BOOL)requiresConstraintBasedLayout
 {
 return YES;
 }
 */

//  Implement the UIGestureRecognizerDelegate delegate to allow both gestureRecognizer and otherGestureRecognizer to recognize their gestures simultaneously.
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handleTouchDown:(BGTouchDownGestureRecognizer *)touchDown{
    NSLog(@"Down");
    
    if(audioRecognizer.delegate == nil) {
        
        _autoScroll = NO;
        [_nsTimer invalidate];
        
        _nsTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(beginAutoScroll) userInfo:nil repeats:NO];
    }
}

- (void)audioRecognized:(ARAudioRecognizer *)recognizer {
    
    audioRecognizer.delegate = nil;
    [self beginAutoScroll];
    m_pManager.webViewMantra.scrollView.scrollEnabled = YES;
}

-(void)beginAutoScroll {

    _autoScroll = YES;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //Do your  Stuff
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView
                  willDecelerate:(BOOL)decelerate
{
    if (!decelerate) {
        //Do your  Stuff
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
 
    if(!otherGlobeView) {

        [self createGlobeIfMaxPositionReached];
    }
}

-(void) createGlobeIfMaxPositionReached {
 
    CGPoint pt = CGPointMake(0, m_pManager.webViewMantra.scrollView.contentOffset.y);
    // If max scroll position reached create real globe
    if(pt.y + m_pManager.webViewMantra.frame.size.height >= m_pManager.webViewMantra.scrollView.contentSize.height) {
        
        _autoScroll = NO;
        [self createGlobe];
    }
}

-(void) createGlobe {
    
    if(self.bounds.size.width > self.bounds.size.height) {
        boundsSquare.size.width = self.bounds.size.width;
        boundsSquare.size.height = self.bounds.size.width;
    } else {
        boundsSquare.size.width = self.bounds.size.height;
        boundsSquare.size.height = self.bounds.size.height;
    }
    boundsSquare.origin.x = 0;
    boundsSquare.origin.y = 0;
    
    otherGlobeView = [[GlobeView alloc] initWithFrame:boundsSquare gameSceneManager:m_pManager beginWithZoom:NO];
    [m_pManager.webViewMantra.scrollView addSubview: otherGlobeView];
    otherGlobeView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *height = [m_pManager.webViewMantra stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    
    if(self.frame.size.width > self.frame.size.height) {
        
        [self updateRealGlobeLandscapeConstraints:[height intValue]];
        
    } else {
        
        [self updateRealGlobePortraitConstraints:[height intValue]];
    }
    
    // Give the globe a little time to form before showing it.
    [NSTimer scheduledTimerWithTimeInterval:3.0 target:self selector:@selector(removeSnapShotGlobeFromBottom) userInfo:nil repeats:NO];
    
}

-(void) updateRealGlobeLandscapeConstraints:(int)height {
    
    int globeY = height - (self.frame.size.height / 2);
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:0.5
                                                                                     constant:0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1
                                                                                     constant:globeY]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1.0
                                                                                     constant:boundsSquare.size.height]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1.0
                                                                                     constant:boundsSquare.size.width]];
    

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1.0
                                                                                     constant:globeWidth + 40]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0
                                                                                     constant:-(globeWidth/6)]];
    
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:lblStatus
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:lblStatus
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1
                                                                                     constant:5]];
    

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.0
                                                                                     constant:-(globeWidth + 40)]];
    
    lblStatus2.text = @"engaged in conscious connection for the benefit of all beings everywhere";
    lblStatus2.textAlignment = NSTextAlignmentLeft;
    
    
    
}

-(void) updateRealGlobePortraitConstraints:(int)height {
    
    int globeY = height - (self.frame.size.height / 1.5);
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1
                                                                                     constant:globeY]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1.0
                                                                                     constant:boundsSquare.size.height]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:nil
                                                                                    attribute:NSLayoutAttributeNotAnAttribute
                                                                                   multiplier:1.0
                                                                                     constant:boundsSquare.size.width]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:otherGlobeView
                                                                                    attribute:NSLayoutAttributeTop
                                                                                   multiplier:1
                                                                                     constant:boundsSquare.size.height - (globeWidth/2)]];
    
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:lblStatus
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1
                                                                                     constant:5]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblStatus2
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    lblStatus2.text = @"engaged in conscious connection\nfor the benefit of all beings everywhere";
    lblStatus2.textAlignment = NSTextAlignmentCenter;
    
    
    
}

- (void) update:(double)delta {
    
    if(_autoScroll) {
        
        CGPoint pt = CGPointMake(0, m_pManager.webViewMantra.scrollView.contentOffset.y);
        pt.y += 1;
        
        if(m_pManager.webViewMantra.scrollView.contentSize.height > pt.y + m_pManager.webViewMantra.frame.size.height) {
            
            // If max scroll position not reached scroll webview
            [m_pManager.webViewMantra.scrollView setContentOffset:CGPointMake(0, pt.y) animated: NO];
            
        } else {
            // Max scroll position reached so end auto scroll
            _autoScroll = NO;
            
            if(!otherGlobeView) {
                
                [self createGlobe];
            }
        }
        
        breathe = false;
    }
    
    if(m_pManager.globeSnapShotView && breathe) {
        
        if(breatheOut) {
            breatheScale +=.003;
            if(breatheScale > 1.1) {
                breatheOut = false;
                
                // End breathing animation if scrolling and at the end of the breathe out cycle.
                if(_autoScroll) {
                    breathe = false;
                }
                
            }
        } else {
            breatheScale -=.003;
            if(breatheScale < 1.0) {
                breatheOut = true;
            }
        }
        m_pManager.globeSnapShotView.transform = CGAffineTransformScale(CGAffineTransformIdentity, breatheScale, breatheScale);
        globeHaloView1.transform = CGAffineTransformScale(CGAffineTransformIdentity, breatheScale, breatheScale);
    }
    
    
    
}

- (void)removeSnapShotGlobeFromBottom {
    
    [m_pManager.globeSnapShotView2 removeFromSuperview];
    
    [UIView animateWithDuration:0.5
                          delay: 0.0
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         [lblStatus setAlpha:1.0];
                         [lblStatus2 setAlpha:1.0];
                     }
                     completion:^(BOOL finished){
                         
                         
                     }];
    
}


- (float) degreesToRadians:(float) degrees {
    
    return degrees * M_PI / 180;
}


- (void) render {
    
    [self setNeedsDisplay]; //this sets up a deferred call to drawRect.
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

- (void)initSnapshotGlobesAndHalos {
    
    globeHaloView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mantra-screen-globe-halo"]];
    globeHaloView1.translatesAutoresizingMaskIntoConstraints = NO;
    [m_pManager.webViewMantra.scrollView addSubview:globeHaloView1];

    m_pManager.globeSnapShotView.translatesAutoresizingMaskIntoConstraints = NO;
    [m_pManager.webViewMantra.scrollView addSubview:m_pManager.globeSnapShotView];

    globeHaloView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mantra-screen-globe-halo"]];
    globeHaloView2.translatesAutoresizingMaskIntoConstraints = NO;
    [m_pManager.webViewMantra.scrollView addSubview:globeHaloView2];
    
    m_pManager.globeSnapShotView2.translatesAutoresizingMaskIntoConstraints = NO;
    [m_pManager.webViewMantra.scrollView addSubview: m_pManager.globeSnapShotView2];
    
}

-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    NSLog(@"GSMantra:updateBounds");
    
    if(orientation == MyViewOrientationPortrait) {
        [self updatePortraitConstraints];
    } else {
        [self updateLandscapeConstraints];
    }
    
}


- (void)updateLandscapeConstraints {
    
    [m_pManager.webViewMantra.scrollView removeConstraints:m_pManager.webViewMantra.scrollView.constraints];
    
    // --------------------- Globe View ----------------------------- //
    
    NSString *height = [m_pManager.webViewMantra stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"HEIGHT:%d", [height intValue]);
    
//    int globeY = [height intValue]-(m_pManager.webViewMantra.frame.size.height/1.5);
    int globeY = [height intValue] - (self.frame.size.height / 2);
    
    if(otherGlobeView) {
        
        [self updateRealGlobeLandscapeConstraints:[height intValue]];
    }
    
    if(globeHaloView2) {
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                       multiplier:0.5
                                                                                         constant:0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeCenterY
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1
                                                                                         constant:globeY]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                       multiplier:1.6
                                                                                         constant:0.0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeWidth
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                       multiplier:1.6
                                                                                         constant:0.0]];
        
    }
    

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                   multiplier:1.0
                                                                                     constant:40.0]];
 

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];



    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                   multiplier:1.6
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                   multiplier:1.6
                                                                                     constant:0.0]];
    

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblBreathe
                                                                                    attribute:NSLayoutAttributeLeft
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeRight
                                                                                   multiplier:1.0
                                                                                     constant:30]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblBreathe
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    if([m_pManager.globeSnapShotView2 superview]!=nil) {
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView2
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                       multiplier:0.5
                                                                                         constant:0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView2
                                                                                        attribute:NSLayoutAttributeCenterY
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1
                                                                                         constant:globeY]];
    }
    
    
    
}

- (void)updatePortraitConstraints {
    
    [m_pManager.webViewMantra.scrollView removeConstraints:m_pManager.webViewMantra.scrollView.constraints];
    
    // --------------------- Globe View ----------------------------- //
    
    NSString *height = [m_pManager.webViewMantra stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"HEIGHT:%d", [height intValue]);
    
    int globeY = [height intValue] - (self.frame.size.height / 1.5);

    
    if(otherGlobeView) {
        
        [self updateRealGlobePortraitConstraints:[height intValue]];
    }

    if(globeHaloView2) {
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                       multiplier:1
                                                                                         constant:0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeCenterY
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1
                                                                                         constant:globeY]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeHeight
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeWidth
                                                                                       multiplier:1.6
                                                                                         constant:0.0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView2
                                                                                        attribute:NSLayoutAttributeWidth
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeWidth
                                                                                       multiplier:1.6
                                                                                         constant:0.0]];
        
    }
   
    
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:0.75
                                                                                     constant:0.0]];

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeCenterY
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.6
                                                                                     constant:0.0]];
    
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:globeHaloView1
                                                                                    attribute:NSLayoutAttributeHeight
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeWidth
                                                                                   multiplier:1.6
                                                                                     constant:0.0]];
    
    
    

    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblBreathe
                                                                                    attribute:NSLayoutAttributeTop
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.globeSnapShotView
                                                                                    attribute:NSLayoutAttributeBottom
                                                                                   multiplier:1.0
                                                                                     constant:60.0]];
  
    [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:lblBreathe
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                    relatedBy:NSLayoutRelationEqual
                                                                                       toItem:m_pManager.webViewMantra.scrollView
                                                                                    attribute:NSLayoutAttributeCenterX
                                                                                   multiplier:1.0
                                                                                     constant:0.0]];
    
    if([m_pManager.globeSnapShotView2 superview]!=nil) {
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView2
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeCenterX
                                                                                       multiplier:1.0
                                                                                         constant:0.0]];
        
        [m_pManager.webViewMantra.scrollView addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.globeSnapShotView2
                                                                                        attribute:NSLayoutAttributeCenterY
                                                                                        relatedBy:NSLayoutRelationEqual
                                                                                           toItem:m_pManager.webViewMantra.scrollView
                                                                                        attribute:NSLayoutAttributeTop
                                                                                       multiplier:1.0
                                                                                         constant:globeY]];
    }
    
    
}


- (void)showBreathText {
    
    lblBreathe = [[UILabel alloc] initWithFrame:CGRectZero];
    lblBreathe.text = @"Breathe";
    lblBreathe.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 40.0];
    lblBreathe.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    [lblBreathe sizeToFit];
    [m_pManager.webViewMantra.scrollView addSubview: lblBreathe];
    lblBreathe.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)showStatusText {
    
    lblStatus = [[UILabel alloc] initWithFrame:CGRectZero];
    lblStatus.text = @"2.5 million people";
    lblStatus.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 30.0];
    lblStatus.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    [lblStatus sizeToFit];
    [m_pManager.webViewMantra.scrollView addSubview: lblStatus];
    lblStatus.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    lblStatus2 = [[UILabel alloc] initWithFrame:CGRectZero];
    lblStatus2.text = @"engaged in conscious connection\nfor the benefit of all beings everywhere";
    lblStatus2.font = [UIFont fontWithName:@"HelveticaNeue-Light" size: 20.0];
    lblStatus2.textColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    lblStatus2.lineBreakMode = NSLineBreakByWordWrapping;
    lblStatus2.numberOfLines = 0;
    lblStatus2.textAlignment = NSTextAlignmentCenter;
    
//    [lblStatus2 sizeToFit];
    [m_pManager.webViewMantra.scrollView addSubview: lblStatus2];
    lblStatus2.translatesAutoresizingMaskIntoConstraints = NO;
    
    [lblStatus setAlpha:0.0];
    [lblStatus2 setAlpha:0.0];

    
}







@end
