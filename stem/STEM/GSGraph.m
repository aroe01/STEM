//
//  GSGraph.m
//  Earth Mantra 2
//
//  Created by Ian on 3/22/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "GSGraph.h"
#import "GSAlarm.h"
#import "GSShare.h"
#import "GSMantra.h"
#import "BGTouchDownGestureRecognizer.h"
#import "BGAnimatingButton.h"


@implementation GSGraph {
    
    //    UITapGestureRecognizer* tapGestureRecognizer;
    BGTouchDownGestureRecognizer* touchDownGestureRecognizer;
    
    BOOL _autoScroll;
    NSTimer *_nsTimer;
    
    //    UIButton *btnShare;
//    UIButton *btnAlarm;
    
    UIImageView *gradientTopImgView;
    UIImageView *gradientBotImgView;
    
}

-(GSGraph*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"GSGraph initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        [self addSubview: manager.webViewGraph];
        manager.webViewGraph.translatesAutoresizingMaskIntoConstraints = NO;
        
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
        NSLog(@"GSGraph didMoveToSuperview: Added to superview");
        
        [self initWebViewConstraints];
        
        _nsTimer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(beginAutoScroll) userInfo:nil repeats:NO];
        
        // Create your custom TouchDownGestureRecognizer: http://stackoverflow.com/questions/15628133/uitapgesturerecognizer-make-it-work-on-touch-down-not-touch-up
        touchDownGestureRecognizer = [[BGTouchDownGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleTouchDown:)];
        
        touchDownGestureRecognizer.cancelsTouchesInView = NO;
        touchDownGestureRecognizer.delegate = self;
        [self addGestureRecognizer:touchDownGestureRecognizer];
        
        
        m_pManager.webViewGraph.scrollView.backgroundColor = [UIColor colorWithRed:0.58 green:0.91 blue:0.83 alpha:1.0];
        //        m_pManager.webViewGraph.scrollView.backgroundColor = [UIColor colorWithRed:255.0 green:255.0 blue:255.0 alpha:1.0];
        
        m_pManager.webViewGraph.delegate = self;
        
        
        gradientTopImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient-top"]];
        gradientTopImgView.translatesAutoresizingMaskIntoConstraints = NO;
        [m_pManager.webViewGraph addSubview:gradientTopImgView];
        
        gradientBotImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"gradient-bot"]];
        gradientBotImgView.translatesAutoresizingMaskIntoConstraints = NO;
        [m_pManager.webViewGraph addSubview:gradientBotImgView];
        
        [self initializeButtons];
        
    } else {
        
        NSLog(@"GSGraph didMoveToSuperview: Removed from superview");
        
        [self removeConstraints:self.constraints];
        [m_pManager.webViewGraph removeConstraints:m_pManager.webViewGraph.constraints];
        
//        [btnAlarm removeFromSuperview];
        //        [btnShare removeFromSuperview];
        
        
    }
}


-(void)webView:(UIWebView *) webView didFailLoadWithError:(NSError *)error {
    NSLog(@"GSGraph:webView didFailLoadWithError");
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"GSGraph:webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    NSLog(@"--------GSGraph webViewDidFinishLoad");
    
    [self updateButtonConstraints];
}


/*
 - (void)updateConstraints
 {
 [super updateConstraints];
 
 CGRect contentRect = CGRectZero;
 for (UIView *view in m_pManager.webViewGraph.scrollView.subviews) {
 contentRect = CGRectUnion(contentRect, view.frame);
 int i = 0;
 }
 }
 */

- (void)layoutSubviews {
    NSLog(@"GSGraph:layoutSubviews");
    
    [super layoutSubviews];
    //    CGFloat contentHeight = m_pManager.webViewGraph.scrollView.contentSize.height;
    //    NSLog(@"--------contentHeight %+.6f\n", contentHeight);
    
    // Use JS to obtain the content height, because m_pManager.webViewGraph.scrollView.contentSize.height, doesn't have the correct size
    // when layoutSubviews is first called
    NSString *height = [m_pManager.webViewGraph stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"**HEIGHT:%d", [height intValue]);
    
    [self updateButtonConstraints];
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
    
    _autoScroll = NO;
    [_nsTimer invalidate];
    
    _nsTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(beginAutoScroll) userInfo:nil repeats:NO];
}

-(void)initializeButtons {
    NSLog(@"--------initializeButtons");

/*
    btnAlarm = [self createButtonWithImageName: @"btn_alarm.png" andID:@"alarm"];
    //    btnShare = [self createButtonWithImageName: @"btn_share.png" andID:@"share"];
    //    [btnAlarm setFrame:CGRectMake(0, contentHeight, 100, 100)];
    //    btnAlarm.center = CGPointMake(0, 150);
    
    [m_pManager.webViewGraph.scrollView addSubview: btnAlarm];
*/
    //    [m_pManager.webViewGraph.scrollView addSubview: btnShare];
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
        //        [m_pManager doSceneChange:[GSMantra class]];
        [m_pManager doSceneChange:[GSAlarm class]];
    } else if([btnTitle isEqualToString:@"share"]) {
        [m_pManager doSceneChange:[GSShare class]];
    }
}

-(void)beginAutoScroll {
    _autoScroll = YES;
}

- (void) update:(double)delta {
    
    if(_autoScroll) {
        
        CGPoint pt = CGPointMake(0, m_pManager.webViewGraph.scrollView.contentOffset.y);
        pt.y += 1;
        if(m_pManager.webViewGraph.scrollView.contentSize.height > pt.y + m_pManager.webViewGraph.frame.size.height) {
            
            //          NSLog(@"contentOffset.y %+.6f\n", pt.y);
            [m_pManager.webViewGraph.scrollView setContentOffset:CGPointMake(0, pt.y) animated: NO];
        } else {
            _autoScroll = NO;
            
        }
    }
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

- (void)initWebViewConstraints {
    
    [self removeConstraints:self.constraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.webViewGraph
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:m_pManager.webViewGraph
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
}

- (void)updateButtonConstraints {
    
    [m_pManager.webViewGraph removeConstraints:m_pManager.webViewGraph.constraints];
    //    [self constrainView:btnAlarm sizeToView:self];
    //    [self constrainView:btnShare sizeToView:self];
    
    // Use JS to obtain the content height
    NSString *height = [m_pManager.webViewGraph stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"HEIGHT:%d", [height intValue]);

/*
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                                   attribute:NSLayoutAttributeCenterY
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:[height intValue]-100]];
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0]];
    
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:50]];
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnAlarm
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:nil
                                                                   attribute:NSLayoutAttributeNotAnAttribute
                                                                  multiplier:1
                                                                    constant:50]];
 */
    
    
    /*
     [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
     attribute:NSLayoutAttributeCenterY
     relatedBy:NSLayoutRelationEqual
     toItem:m_pManager.webViewGraph.scrollView
     attribute:NSLayoutAttributeTop
     multiplier:1
     constant:[height intValue]-100]];
     
     [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
     attribute:NSLayoutAttributeCenterX
     relatedBy:NSLayoutRelationEqual
     toItem:m_pManager.webViewGraph.scrollView
     attribute:NSLayoutAttributeCenterX
     multiplier:1.3
     constant:0]];
     
     [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
     attribute:NSLayoutAttributeWidth
     relatedBy:NSLayoutRelationEqual
     toItem:nil
     attribute:NSLayoutAttributeNotAnAttribute
     multiplier:1
     constant:50]];
     
     [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:btnShare
     attribute:NSLayoutAttributeHeight
     relatedBy:NSLayoutRelationEqual
     toItem:nil
     attribute:NSLayoutAttributeNotAnAttribute
     multiplier:1
     constant:50]];
     */
    
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:gradientTopImgView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:0]];
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:gradientTopImgView
                                                                   attribute:NSLayoutAttributeTop
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeTop
                                                                  multiplier:1
                                                                    constant:0]];
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:gradientBotImgView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:0]];
    
    [m_pManager.webViewGraph addConstraint:[NSLayoutConstraint constraintWithItem:gradientBotImgView
                                                                   attribute:NSLayoutAttributeBottom
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:m_pManager.webViewGraph.scrollView
                                                                   attribute:NSLayoutAttributeBottom
                                                                  multiplier:1
                                                                    constant:0]];
    
    
}

-(void)constrainView:(id)view sizeToView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.12
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.12
                                                      constant:0]];
    
}

-(void)constrainView:(id)view sizeToLandscapeView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.12
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.12
                                                      constant:0]];
}

-(void)constrainView:(id)view leftOfView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTrailing
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeLeading
                                                    multiplier:1.0
                                                      constant:-16.0]];
}

-(void)constrainViewTops:(id)view toView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeTop
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeTop
                                                    multiplier:1.0
                                                      constant:0]];
    
}
@end
