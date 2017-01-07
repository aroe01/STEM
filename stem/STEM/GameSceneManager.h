//
//  GameStateController.h
//  One Earth
//
//  Created by Ian on 9/13/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <CoreLocation/CoreLocation.h>

@interface GameSceneManager : UIViewController<MFMailComposeViewControllerDelegate, UIDocumentInteractionControllerDelegate, UIWebViewDelegate, CLLocationManagerDelegate>

@property (readonly) float fps;
@property (nonatomic, strong, readonly) UIWebView* webView;
@property (nonatomic, strong, readonly) UIWebView* webViewMantra;
@property (nonatomic, strong, readonly) UIWebView* webViewGraph;
@property (nonatomic, strong, readonly) UIWebView* webViewNews;

@property (nonatomic, strong) UIImageView* globeSnapShotView;
@property (nonatomic, strong) UIView* globeSnapShotView2;

@property (nonatomic, strong) CLLocationManager *locationManager;


//@property (nonatomic, strong) UIWebView* webView;


typedef NS_ENUM(NSInteger, MyViewOrientation) {
    MyViewOrientationUnspecified,
    MyViewOrientationPortrait,
    MyViewOrientationLandscape,
};

- (id)initFromAlarmFired;
- (void) doSceneChange: (Class) scene;
- (int) getFramesPerSecond;
- (void)instagramOpenDocument;

- (void)initLocationManager;
- (MyViewOrientation) deviceOrientation;

@end
