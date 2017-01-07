//
//  GameStateController.m
//  One Earth
//
//  Created by Ian on 9/13/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "GameSceneManager.h"
#import "GameScene.h"
#import "GSGlobe.h"
#import "GSIntro.h"
#import "GSMantra.h"
#import "GSMainMenu.h"

#define LOOP_TIMER_MINIMUM 0.033f

@implementation GameSceneManager {
    
    // Instance variable declarations go here (starting in iOS 5). Note the curly braces. Since they are by default private, its more logical to put them here along with the implementation
    CFTimeInterval m_FPS_lastSecondStart;
    int m_FPS_framesThisSecond;
    CFTimeInterval m_lastUpdateTime;
    float m_estFramesPerSecond;
    int m_FPS;
    
    BOOL m_initFromAlarmFired;
    
    UIDocumentInteractionController *documentInteractionController;
    
//    UIImageView *gradientTopImgView;


}

- (id)init
{
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        
        NSLog(@"Initializing the GameSceneManager");
        
        // Start the main loop
        [NSTimer scheduledTimerWithTimeInterval:LOOP_TIMER_MINIMUM target:self selector:@selector(gameLoop:) userInfo:nil repeats:NO];
        m_lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        m_FPS_lastSecondStart = m_lastUpdateTime;
        m_FPS_framesThisSecond = 0;
        
        m_initFromAlarmFired = NO;
        
        
        
    }
    return self;
}

- (id)initFromAlarmFired {
    
    self = [super init];
    if (self)
    {
        // superclass successfully initialized, further
        // initialization happens here ...
        
        NSLog(@"Initializing the GameSceneManager");
        
        // Start the main loop
        [NSTimer scheduledTimerWithTimeInterval:LOOP_TIMER_MINIMUM target:self selector:@selector(gameLoop:) userInfo:nil repeats:NO];
        m_lastUpdateTime = [[NSDate date] timeIntervalSince1970];
        m_FPS_lastSecondStart = m_lastUpdateTime;
        m_FPS_framesThisSecond = 0;
        
        m_initFromAlarmFired = YES;
        
    }
    return self;
    
}

- (void) doSceneChange: (Class) scene {
    NSLog(@"GameSceneManager doSceneChange");
    
    GameScene* currentGS = [self.view.subviews firstObject];
    if(currentGS) {
        
        UIView* newGS = [[scene alloc] initWithFrame:self.view.bounds gameSceneManager:self];
        // Allow parent view to resize this view when the parent resizes. See https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/index.html#//apple_ref/occ/instp/UIView/autoresizingMask
        newGS.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        
        
        [UIView transitionFromView:currentGS
                            toView:newGS
                            duration:0.4f
                            options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL done){
                            
                                unsigned long numChildren = [self.view.subviews count];
                                NSLog(@"there are %lu objects in the array", numChildren);
                        }];
    } else {
        //    UIView* newGS = [[scene alloc] initWithFrame:CGRectMake(0, 0, 200, 200) andManager:self];
        UIView* newGS = [[scene alloc] initWithFrame:self.view.bounds gameSceneManager:self];
        // Allow parent view to resize this view when the parent resizes. See https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIView_Class/index.html#//apple_ref/occ/instp/UIView/autoresizingMask
        newGS.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin |
        UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin |
        UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [self.view addSubview:newGS];
        
        unsigned long numChildren = [self.view.subviews count];
        NSLog(@"there are %lu objects in the array", numChildren);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"GameSceneManager viewDidLoad");
    self.view.backgroundColor = [UIColor whiteColor];

    // Initialize the UIWebView for the Info screen
    NSString *fullURL = @"http://www.binarygizmo.com/jens-site.com/";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    self->_webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self->_webView.delegate = self;
    [self->_webView loadRequest:requestObj];

    // Initialize the UIWebView for the Info screen
    NSString *strMantraURL = @"http://www.binarygizmo.com/jens-site.com/mantra";
    NSURL *urlMantra = [NSURL URLWithString:strMantraURL];
    NSURLRequest *requestObjMantra = [NSURLRequest requestWithURL:urlMantra];
    self->_webViewMantra=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self->_webViewMantra.delegate = self;
    [self->_webViewMantra loadRequest:requestObjMantra];

    
    // Initialize the UIWebView for the Graph screen
    NSString *strGraphURL = @"http://www.binarygizmo.com/jens-site.com/graph";
    NSURL *urlGraph = [NSURL URLWithString:strGraphURL];
    NSURLRequest *requestObjGraph = [NSURLRequest requestWithURL:urlGraph];
    self->_webViewGraph=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self->_webViewGraph.delegate = self;
    [self->_webViewGraph loadRequest:requestObjGraph];

    // Initialize the UIWebView for the Info screen
    NSString *strNewsURL = @"http://www.binarygizmo.com/jens-site.com/news";
    NSURL *urlNews = [NSURL URLWithString:strNewsURL];
    NSURLRequest *requestObjNews = [NSURLRequest requestWithURL:urlNews];
    self->_webViewNews=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
    self->_webViewNews.delegate = self;
    [self->_webViewNews loadRequest:requestObjNews];
    
    
    [self initLocationManager];
    
    
    if(m_initFromAlarmFired) {
        [self doSceneChange:[GSMantra class]];
    } else {
        [self doSceneChange:[GSIntro class]];
    }
}

- (void)initLocationManager {
    
    self.locationManager = [[CLLocationManager alloc] init];
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    // Also added the 'NSLocationWhenInUseUsageDescription' row to the info.plist file; without it this code fails.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    [_locationManager startUpdatingLocation];
    
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



-(void)webView:(UIWebView *) webView didFailLoadWithError:(NSError *)error {
    NSLog(@"GameSceneManager:webView didFailLoadWithError");
}

-(void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"GameSceneManager:webViewDidStartLoad");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
 
    NSLog(@"--------GameSceneManager webViewDidFinishLoad");

/*
    CGFloat contentHeight = webView.scrollView.contentSize.height;
    NSLog(@"contentHeight %+.6f\n", contentHeight);
    
    CGRect contentRect = CGRectZero;
    for (UIView *view in webView.scrollView.subviews) {
        contentRect = CGRectUnion(contentRect, view.frame);
    }
    webView.scrollView.contentSize = contentRect.size;
    NSLog(@"#########contentHeight %+.6f\n", contentRect.size.height);
    
    
    
    CGRect frame = webView.frame;
    frame.size.height = 1;
    webView.frame = frame;
    CGSize fittingSize = [webView sizeThatFits:CGSizeZero];
    frame.size = fittingSize;
    webView.frame = frame;
    
    NSLog(@"+++++++++++++++++++++++size: %f, %f", fittingSize.width, fittingSize.height);
    
    
    NSString *height = [webView stringByEvaluatingJavaScriptFromString:@"document.body.scrollHeight;"];
    NSLog(@"$$$$$$$$$$$$$$$$$ contentHeight %d\n", [height intValue]);
*/
    
 }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
    One of the things the game loop does is calculate the FPS. Using the following:
    Each time the loop is executed, m_FPS_framesThisSecond is increment
    m_FPS_lastSecondStart is the start time of the last second
    currTime is the current time
    timeThisSecond = currTime - m_FPS_lastSecondStart is the amount of time that has past since the start of the last second. When this reaches 1 second the code does the following:
    1. sets the FPS to m_FPS_framesThisSecond
    2. resets m_FPS_framesThisSecond to 0
    3. sets the m_FPS_lastSecondStart to currTime, making this the new start of the last second.
 
    Note: delta is the number of miliseconds since the late frame
 
 */
- (void) gameLoop:(id) sender
{

    double currTime = [[NSDate date] timeIntervalSince1970];
    double delta = currTime - m_lastUpdateTime;
//    NSLog(@"delta %+.6f\n", delta);
    
    GameScene* currentGS = [self.view.subviews firstObject];
    if(currentGS) {
        [currentGS update: delta];
        [currentGS render];
    }
    
    m_FPS_framesThisSecond++;
    float timeThisSecond = currTime - m_FPS_lastSecondStart;
    if( timeThisSecond > 1.0f ) {
        m_FPS = m_FPS_framesThisSecond;
        m_FPS_framesThisSecond = 0;
        m_FPS_lastSecondStart = currTime;
    }
    
    [NSTimer scheduledTimerWithTimeInterval:LOOP_TIMER_MINIMUM target:self selector:@selector(gameLoop:) userInfo:nil repeats:NO];
    
    m_lastUpdateTime = currTime;
}

- (int) getFramesPerSecond{
    return m_FPS;
}

/*
- (void)viewDidLayoutSubviews {
    
    NSLog(@"GameStateManager: viewDidLayoutSubviews ");
    
    CGFloat contentHeight = self->_webView.scrollView.contentSize.height;
    NSLog(@"--------contentHeight %+.6f\n", contentHeight);
    
    
}
*/

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    // See http://imnotyourson.com/ios-adaptive-layout-with-rotation-tips/
    
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Code here will execute before the rotation begins.
    // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
    
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Place code here to perform animations during the rotation.
        // You can pass nil or leave this block empty if not necessary.
        
        NSLog(@"GameStateManager: viewWillTransitionToSize ");
        
        MyViewOrientation orientation;
        if(size.width > size.height) {
            NSLog(@"Orienatation Landscape");
            orientation = MyViewOrientationLandscape;
        } else {
            NSLog(@"Orienatation Portrait");
            orientation = MyViewOrientationPortrait;
        }
        
        GameScene* currentGS = [self.view.subviews firstObject];
        if(currentGS) {
            CGFloat scale =  [UIScreen mainScreen].scale;
            [currentGS updateBounds:size orientation:orientation scale:scale];
        }
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        
        // Code here will execute after the rotation has finished.
        // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
        
    }];
}

- (MyViewOrientation) deviceOrientation {
    
    MyViewOrientation orientation;
    if(self.view.bounds.size.width > self.view.bounds.size.height) {
        NSLog(@"Orienatation Landscape");
        orientation = MyViewOrientationLandscape;
    } else {
        NSLog(@"Orienatation Portrait");
        orientation = MyViewOrientationPortrait;
    }

    return orientation;
}

/*
- (UIInterfaceOrientationMask) supportedInterfaceOrientations {
    // Return a bitmask of supported orientations. If you need more,
    // use bitwise or (see the commented return).
    return UIInterfaceOrientationMaskPortrait;
//    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscape;
    // return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation {
    // Return the orientation you'd prefer - this is what it launches to. The
    // user can still rotate. You don't have to implement this method, in which
    // case it launches in the current orientation
    return UIInterfaceOrientationPortrait;
//    return UIInterfaceOrientationPortrait | UIInterfaceOrientationLandscapeRight | UIInterfaceOrientationLandscapeLeft;
}
*/

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result) {
        case MFMailComposeResultSent:
            NSLog(@"You sent the email.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"You saved a draft of this email");
            break;
        case MFMailComposeResultCancelled:
            NSLog(@"You cancelled sending this email.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed:  An error occurred when trying to compose this email");
            break;
        default:
            NSLog(@"An error occurred when trying to compose this email");
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)instagramOpenDocument {
    NSLog(@"instagramPreviewDocument");
    
    // http://code.tutsplus.com/tutorials/ios-sdk-previewing-and-opening-documents--mobile-15130
    
    NSURL *URL = [[NSBundle mainBundle] URLForResource:@"share-screen" withExtension:@"igo"];
    
    if (URL) {
        // Initialize Document Interaction Controller
        documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:URL];
        documentInteractionController.UTI = @"com.instagram.exclusivegram";
        
        // Configure Document Interaction Controller
        [documentInteractionController setDelegate:self];
        
//        [documentInteractionController presentPreviewAnimated:YES];
        
        // Nolonger able to pre-fill captions: http://developers.instagram.com/post/125972775561/removing-pre-filled-captions-from-mobile-sharing
        //documentInteractionController.annotation = [NSDictionary dictionaryWithObject:@"Caption Test" forKey:@"InstagramCaption"];
        
        [documentInteractionController presentOpenInMenuFromRect:CGRectZero inView:self.view animated:YES];
        
    }
}

- (UIViewController *) documentInteractionControllerViewControllerForPreview: (UIDocumentInteractionController *) controller {
    return self;
}


@end
