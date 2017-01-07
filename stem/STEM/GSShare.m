//
//  GSShare.m
//  Earth Mantra 2
//
//  Created by Ian on 11/7/15.
//  Copyright © 2015 Binary Gizmo. All rights reserved.
//

#import "GSShare.h"
#import <SceneKit/SceneKit.h>

@import MessageUI;
@import Social;
#import "GSGlobe.h"
#import "GSInfo.h"
#import "GSMantra.h"

#import "GSMainMenu.h"
#import "OrbView.h"
#import "BGTouchDownGestureRecognizer.h"




//#import <MessageUI/MessageUI.h>


@implementation GSShare {
    
//    UIImageView *imgView;
    
//    UIImageView *backgroundPortraitImgView;
    
    UIImageView *handsPortraitImgView;
    UIImageView *lensFlarePortraitImgView;
    UIImageView *raysPortraitImgView;

    UIImageView *handsLandscapeImgView;
    UIImageView *lensFlareLandscapeImgView;
    UIImageView *raysLandscapeImgView;
    
    UIButton *btnDonate;
    UIButton *btnFacebook;
    UIButton *btnMail;
    UIButton *btnTwitter;
    UIButton *btnInstagram;
    
    SCNView *globeView;
    
    float breatheScale;
    BOOL breatheOut;
    
    OrbView *orb;
    BGTouchDownGestureRecognizer* touchDownGestureRecognizer;
    
}

-(GSShare*) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"GSShare initWithFrame:andManager");
    
    if (self = [super initWithFrame:frame gameSceneManager:manager]) {
        //do initializations here.
        
        self.backgroundColor = [UIColor greenColor];
        self.contentMode = UIViewContentModeScaleAspectFill;
        
        breatheScale = 1.0;
        breatheOut = false;
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
        NSLog(@"GSShare didMoveToSuperview: Added to superview");
        [self initShareScene];
        
        orb =[[OrbView alloc]initWithFrame:CGRectMake((self.bounds.size.width/2), (self.bounds.size.height/2), 200, 200)];
        [self addSubview:orb];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected)];
        singleTap.numberOfTapsRequired = 1;
        [orb setUserInteractionEnabled:YES];
        [orb addGestureRecognizer:singleTap];
        
        
        // Create your custom TouchDownGestureRecognizer: http://stackoverflow.com/questions/15628133/uitapgesturerecognizer-make-it-work-on-touch-down-not-touch-up
        touchDownGestureRecognizer = [[BGTouchDownGestureRecognizer alloc]
                                      initWithTarget:self
                                      action:@selector(handleTouchDown:)];
        
        touchDownGestureRecognizer.cancelsTouchesInView = NO;
        touchDownGestureRecognizer.delegate = self;
        [self addGestureRecognizer:touchDownGestureRecognizer];
        
        
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

-(void)handleTouchDown:(BGTouchDownGestureRecognizer *)touchDown{
    NSLog(@"Down");
    [orb wakeUpWithDelay:0.0];
    
}

-(void)tapDetected{
    NSLog(@"single Tap on imageview");
    [m_pManager doSceneChange:[GSMainMenu class]];
    
}

- (void)initShareScene {
    
    MyViewOrientation orientation;
    if(self.bounds.size.width > self.bounds.size.height) {
        orientation = MyViewOrientationLandscape;
    } else {
        orientation = MyViewOrientationPortrait;
    }
    
    [self initButtons];
    [self initGlobe];
    
    CGFloat scale =  [UIScreen mainScreen].scale;
    [self updateBounds:self.bounds.size orientation:orientation scale:scale];
  
/*
    [UIView animateWithDuration:100
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
                     animations:^{
//                         [UIView setAnimationRepeatCount:200]; // **This should appear in the beginning of the block**
//                         globeView.alpha = 0.0;
                         globeView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
                         
                     }
                     completion:nil];
*/
    
// options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionRepeat | UIViewAnimationOptionAutoreverse
    
    
}





- (void)initButtons {

    btnDonate = [self createButtonWithImageName: @"btn_donate.png" andID:@"donate"];
  //  btnDonate.showsTouchWhenHighlighted = YES;
    [btnDonate setImage:[UIImage imageNamed: @"btn_donate_glow.png"] forState:UIControlStateHighlighted];
    
    
    btnFacebook = [self createButtonWithImageName: @"btn_facebook.png" andID:@"facebook"];
   // btnFacebook.showsTouchWhenHighlighted = YES;
    [btnFacebook setImage:[UIImage imageNamed: @"btn_facebook_glow.png"] forState:UIControlStateHighlighted];
    
    btnMail = [self createButtonWithImageName: @"btn_mail.png" andID:@"mail"];
  //  btnMail.showsTouchWhenHighlighted = YES;
    [btnMail setImage:[UIImage imageNamed: @"btn_mail_glow.png"] forState:UIControlStateHighlighted];
    
    btnTwitter = [self createButtonWithImageName: @"btn_twitter.png" andID:@"twitter"];
//    btnTwitter.showsTouchWhenHighlighted = YES;
    [btnTwitter setImage:[UIImage imageNamed: @"btn_twitter_glow.png"] forState:UIControlStateHighlighted];
    
    btnInstagram = [self createButtonWithImageName: @"btn_instagram.png" andID:@"instagram"];
//    btnInstagram.showsTouchWhenHighlighted = YES;
    [btnInstagram setImage:[UIImage imageNamed: @"btn_instagram_glow.png"] forState:UIControlStateHighlighted];
    
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
    
    [self addSubview:btn];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    return btn;
}

- (void)initGlobe {
    
    CGRect rect = CGRectMake(0, 0, 200, 200);
    
    globeView = [[SCNView alloc] initWithFrame:rect];
//    globeView = [[SCNView alloc] initWithFrame:self.bounds];
    globeView.backgroundColor = [UIColor clearColor];
//    globeView.backgroundColor = [UIColor redColor];
    [self addSubview:globeView];
    globeView.translatesAutoresizingMaskIntoConstraints = NO;

    
    // An empty scene
    SCNScene *scene = [SCNScene scene];
    globeView.scene = scene;
   
/*
    SCNScene *scene = [SCNScene sceneNamed:@"earth_mesh.dae"];
    globeView.scene = scene;
*/
/*
    SCNScene *spaceshipX = [SCNScene sceneNamed:@"Spaceship.dae"];
    SCNNode *spaceship = [spaceshipX.rootNode childNodeWithName:@"Spaceship" recursively:YES];
    [scene.rootNode addChildNode:spaceship];
*/

    SCNNode *globeNode = [SCNNode node];

    SCNScene *globe = [SCNScene sceneNamed:@"earth_mesh.dae"];
    
    
    
    SCNNode *highlights = [globe.rootNode childNodeWithName:@"highlights_mesh" recursively:YES];
//    highlights.geometry.firstMaterial.specular.contents = [UIColor whiteColor];
    [globeNode addChildNode : highlights];

    SCNNode *veins = [globe.rootNode childNodeWithName:@"veins_mesh" recursively:YES];
//    veins.geometry.firstMaterial.specular.contents = [UIColor whiteColor];    
    [globeNode addChildNode : veins];

    SCNNode *sparkles = [globe.rootNode childNodeWithName:@"sparkles_mesh" recursively:YES];
    [globeNode addChildNode : sparkles];

    SCNNode *continents = [globe.rootNode childNodeWithName:@"continents_mesh" recursively:YES];
    continents.opacity = 0.4;
    continents.opacity = 1;
//    continents.scale = SCNVector3Make(0.9, 0.9, 0.9); //rotate around Y a small angle
    continents.rotation = SCNVector4Make(0, 1, 0, M_PI/2.0); //rotate around Y a small angle
    [globeNode addChildNode : continents];
    
    globeNode.rotation = SCNVector4Make(0, 1, 0, M_PI/2.0); //rotate around Y a small angle
    [scene.rootNode addChildNode : globeNode];
    
//    globeView.autoenablesDefaultLighting = TRUE;
    
    // A camera looking down at the box
    // --------------------------------
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera   = [SCNCamera camera];
    cameraNode.position = SCNVector3Make(0, 0, 17.3);
/*
    cameraNode.rotation = SCNVector4Make(1, 0, 0, // rotate around X
                                         -atan2(10.0, 20.0)); // atan(camY/camZ)
*/
    [scene.rootNode addChildNode:cameraNode];
 
    
    // A light blue directional light
    // ------------------------------


    UIColor *lightColor = [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0];
    
    SCNLight *light = [SCNLight light];
    light.type  = SCNLightTypeDirectional;
    light.color = lightColor;
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = light;
    [cameraNode addChildNode:lightNode];

/*
    SCNLight *spotlight = [SCNLight light];
    spotlight.type  = SCNLightTypeSpot;
    spotlight.color = lightColor;
    SCNNode *spotlightNode = [SCNNode node];
    spotlightNode.light = spotlight;
    [cameraNode addChildNode:spotlightNode];
*/

    UIColor *ambientLightColor = [UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0];
    SCNLight *ambientLight = [SCNLight light];
    ambientLight.type  = SCNLightTypeAmbient;
    ambientLight.color = ambientLightColor;
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = ambientLight;
    [scene.rootNode addChildNode:ambientLightNode];

    
    
}

- (void)initPortraitConstraints {
    
    // -------------------------
    
    [self removeConstraints:self.constraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-64.0]];
    
    
    // Center horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // --------------------- Globe View ----------------------------- //


    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:.8
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.3
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.3
                                                      constant:0]];
    
    
    // --------------------- Lens flare ----------------------------- //
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlarePortraitImgView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlarePortraitImgView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.8
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlarePortraitImgView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlarePortraitImgView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:1
                                                      constant:0]];
    
    
    
    // ------------------------- Constrain button's width and height ----------------- //
    
    [self constrainView:btnDonate sizeToView:self];
    [self constrainView:btnFacebook sizeToView:self];
    [self constrainView:btnMail sizeToView:self];
    [self constrainView:btnTwitter sizeToView:self];
    [self constrainView:btnInstagram sizeToView:self];
    
    // ------------------------- Constrain buttons lefts ----------------- //
    
    [self constrainView:btnFacebook leftOfView:btnDonate];
    [self constrainView:btnDonate leftOfView:btnMail];
    [self constrainView:btnTwitter leftOfView:btnFacebook];
    [self constrainView:btnMail leftOfView:btnInstagram];
    
    // ------------------------- Constrain buttons top to same as btnDonate ----------------- //
    
    [self constrainViewTops:btnFacebook toView:btnDonate];
    [self constrainViewTops:btnMail toView:btnDonate];
    [self constrainViewTops:btnTwitter toView:btnDonate];
    [self constrainViewTops:btnInstagram toView:btnDonate];


    
//    [self constrainView:backgroundPortraitImgView sizeToView:self];

/*
    backgroundPortraitImgView.translatesAutoresizingMaskIntoConstraints = NO;
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:backgroundPortraitImgView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.5
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:backgroundPortraitImgView
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.5
                                                      constant:0]];
    */
    

    
    
}
- (void)initLandscapeConstraints {

    [self removeConstraints:self.constraints];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeBottom
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeBottom
                                                    multiplier:1.0
                                                      constant:-64.0]];
    
    
    // Center horizontally
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // Center vertically
    [self addConstraint:[NSLayoutConstraint constraintWithItem:btnDonate
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    // --------------------- Globe View ----------------------------- //
    
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:.72
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.3
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:globeView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.3
                                                      constant:0]];
    
    
    
    
    // --------------------- Lens flare ----------------------------- //
    

    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlareLandscapeImgView
                                                     attribute:NSLayoutAttributeCenterX
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterX
                                                    multiplier:1.0
                                                      constant:0.0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlareLandscapeImgView
                                                     attribute:NSLayoutAttributeCenterY
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeCenterY
                                                    multiplier:0.8
                                                      constant:0.0]];

    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlareLandscapeImgView
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:lensFlareLandscapeImgView
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:self
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:1
                                                      constant:0]];

    
    
    // --------------------- Rays ----------------------------- //

    
    
    
    
    // ------------------------- Constrain button's width and height ----------------- //
    
    [self constrainView:btnDonate sizeToLandscapeView:self];
    [self constrainView:btnFacebook sizeToLandscapeView:self];
    [self constrainView:btnMail sizeToLandscapeView:self];
    [self constrainView:btnTwitter sizeToLandscapeView:self];
    [self constrainView:btnInstagram sizeToLandscapeView:self];
    
    // ------------------------- Constrain buttons lefts ----------------- //
    
    [self constrainView:btnFacebook leftOfView:btnDonate];
    [self constrainView:btnDonate leftOfView:btnMail];
    [self constrainView:btnTwitter leftOfView:btnFacebook];
    [self constrainView:btnMail leftOfView:btnInstagram];
    
    // ------------------------- Constrain buttons top to same as btnDonate ----------------- //
    
    [self constrainViewTops:btnFacebook toView:btnDonate];
    [self constrainViewTops:btnMail toView:btnDonate];
    [self constrainViewTops:btnTwitter toView:btnDonate];
    [self constrainViewTops:btnInstagram toView:btnDonate];
    
    
    
    
    
}

-(void)constrainView:(id)view sizeToView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.15
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeWidth
                                                    multiplier:0.15
                                                      constant:0]];
}

-(void)constrainView:(id)view sizeToLandscapeView:(id)view2 {
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeWidth
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.15
                                                      constant:0]];
    
    [self addConstraint:[NSLayoutConstraint constraintWithItem:view
                                                     attribute:NSLayoutAttributeHeight
                                                     relatedBy:NSLayoutRelationEqual
                                                        toItem:view2
                                                     attribute:NSLayoutAttributeHeight
                                                    multiplier:0.15
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

//-(void) updateBounds:(CGSize)size withOrientation:(MyViewOrientation)orientation {
-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    NSLog(@"GSShare:updateBounds");
    [self setShareScreenBackground:size orientation:orientation scale:scale];
    [self showButtons];

}

-(void)setShareScreenBackground:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
    if(orientation == MyViewOrientationPortrait) {
        
        NSLog(@"setShareScreenBackground:MyViewOrientationPortrait");
        if(scale == 2.f && size.height == 480 ) {       // Point size 480, Device size 960
            NSLog(@"iPhone 4s");
            [self displayPortraitSceneBackground:@"share-scene-bg-640x960.jpg"
                                           hands:@"share-scene-bg-hands-640x960.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-640x960.png"];
            
        } else if (scale == 2.f && size.height == 568 ) { // Point size 568, Device size 1136
            NSLog(@"iPhone 5, 5s");

            [self displayPortraitSceneBackground:@"share-scene-bg-640x1136.jpg"
                                           hands:@"share-scene-bg-hands-640x1136.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-640x1136.png"];
            
            
        } else if (scale == 2.f && size.height == 667) { // Point size 667, Device size 1334
            NSLog(@"iPhone 6");
            
            [self displayPortraitSceneBackground:@"share-scene-bg-750x1334.jpg"
                                           hands:@"share-scene-bg-hands-750x1334.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-750x1334.png"];
            
        } else if (scale == 3.f && size.height == 736) { // Point size 736, Device size 2208
            NSLog(@"iPhone 6Plus / 6sPlus");
            [self displayPortraitSceneBackground:@"share-scene-bg-1242x2208.jpg"
                                           hands:@"share-scene-bg-hands-1242x2208.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-1242x2208.png"];
            
        } else if (scale == 1.f && size.height == 1024) { // Point size ???, Device size 1024
            NSLog(@"iPad 2");

            [self displayPortraitSceneBackground:@"share-scene-bg-768x1024.jpg"
                                            hands:@"share-scene-bg-hands-768x1024.png"
                                            lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-768x1024.png"];

        } else if (scale == 2.f && size.height == 1024) { // Point size ???, Device size 2048
            NSLog(@"iPad Retina / iPad Air / iPad Air 2");
            [self displayPortraitSceneBackground:@"share-scene-bg-1536x2048.jpg"
                                           hands:@"share-scene-bg-hands-1536x2048.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-1536x2048.png"];
            
        } else {
            NSLog(@"??????????");
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"share-scene-bg-768x1024.jpg"]];
        }
        
        [self initPortraitConstraints];
        
        
    } else {
        NSLog(@"setShareScreenBackground:MyViewOrientationLandscape");
        if(scale == 2.f && size.width == 480 ) {       // Point size 480, Device size 960
            NSLog(@"iPhone 4s");
            [self displayLandscapeSceneBackground:@"share-scene-bg-960x640.jpg"
                                            hands:@"share-scene-bg-hands-960x640.png"
                                        lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                             rays:@"share-scene-bg-rays-960x640.png"];
            
        } else if (scale == 2.f && size.width == 568 ) { // Point size 568, Device size 1136
            NSLog(@"iPhone 5, 5s, 6");
            
            [self displayLandscapeSceneBackground:@"share-scene-bg-1136x640.jpg"
                                            hands:@"share-scene-bg-hands-1136x640.png"
                                        lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                             rays:@"share-scene-bg-rays-1136x640.png"];
            
            
        } else if (scale == 2.f && size.width == 667) { // Point size 667, Device size 1334
            NSLog(@"iPhone 6");
            
            [self displayLandscapeSceneBackground:@"share-scene-bg-1334x750.jpg"
                                           hands:@"share-scene-bg-hands-1334x750.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-1334x750.png"];
            
        } else if (scale == 3.f && size.width == 736) { // Point size 736, Device size 2208
            NSLog(@"iPhone 6Plus / 6sPlus");
            [self displayLandscapeSceneBackground:@"share-scene-bg-2208x1242.jpg"
                                            hands:@"share-scene-bg-hands-2208x1242.png"
                                        lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                             rays:@"share-scene-bg-rays-2208x1242.png"];
        } else if (scale == 1.f && size.width == 1024) { // Point size ???, Device size 1024
            NSLog(@"iPad 2");
            
            [self displayLandscapeSceneBackground:@"share-scene-bg-1024x768.jpg"
                                           hands:@"share-scene-bg-hands-1024x768.png"
                                       lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                            rays:@"share-scene-bg-rays-1024x768.png"];
            
        } else if (scale == 2.f && size.width == 1024) { // Point size ???, Device size 2048
            NSLog(@"iPad Retina / iPad Air / iPad Air 2");
            [self displayLandscapeSceneBackground:@"share-scene-bg-2048x1536.jpg"
                                            hands:@"share-scene-bg-hands-2048x1536.png"
                                        lensFlare:@"share-scene-bg-lens-flare-762x762.png"
                                             rays:@"share-scene-bg-rays-2048x1536.png"];
            
        } else {
            NSLog(@"??????????");
            self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"share-scene-bg-1024x768.jpg"]];
        }
        
        [self initLandscapeConstraints];
        
    }
    
    NSLog(@"Scale = %f", scale);
    NSLog(@"Size = %f", size.height);
    
}

-(void)displayPortraitSceneBackground:(NSString *)background hands:(NSString *)hands lensFlare:(NSString *)lensFlare rays:(NSString *)rays {
    NSLog(@"displayPortraitSceneBackground");
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:background]];
    
    if(handsLandscapeImgView) {
        [handsLandscapeImgView removeFromSuperview];
        handsLandscapeImgView = nil;
    }
    if(lensFlareLandscapeImgView) {
        [lensFlareLandscapeImgView removeFromSuperview];
    }
    if(raysLandscapeImgView) {
        [raysLandscapeImgView removeFromSuperview];
        raysLandscapeImgView = nil;
    }

    [self showGlobe];
    
//    backgroundPortraitImgView  = [[UIImageView alloc] initWithImage:[UIImage imageNamed:background]];
//    [self addSubview:backgroundPortraitImgView];
    
    handsPortraitImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:hands]];
    [self addSubview:handsPortraitImgView];
    lensFlarePortraitImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:lensFlare]];
    [self addSubview:lensFlarePortraitImgView];
    lensFlarePortraitImgView.translatesAutoresizingMaskIntoConstraints = NO;

    raysPortraitImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rays]];
    [self addSubview:raysPortraitImgView];
    
}

-(void)displayLandscapeSceneBackground:(NSString *)background hands:(NSString *)hands lensFlare:(NSString *)lensFlare rays:(NSString *)rays {
    NSLog(@"displayLandscapeSceneBackground");
    
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:background]];
    
    if(handsPortraitImgView) {
        [handsPortraitImgView removeFromSuperview];
        handsPortraitImgView = nil;
    }
    if(lensFlarePortraitImgView) {
        [lensFlarePortraitImgView removeFromSuperview];
    }
    if(raysPortraitImgView) {
        [raysPortraitImgView removeFromSuperview];
        raysPortraitImgView = nil;
    }
    
    [self showGlobe];
    
    handsLandscapeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:hands]];
    [self addSubview:handsLandscapeImgView];
    lensFlareLandscapeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:lensFlare]];
    [self addSubview:lensFlareLandscapeImgView];
    lensFlareLandscapeImgView.translatesAutoresizingMaskIntoConstraints = NO;
    
    raysLandscapeImgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:rays]];
    [self addSubview:raysLandscapeImgView];
    
}

- (void)showButtons {
    NSLog(@"showButtons");
    [self bringSubviewToFront:btnDonate];
    [self bringSubviewToFront:btnFacebook];
    [self bringSubviewToFront:btnMail];
    [self bringSubviewToFront:btnTwitter];
    [self bringSubviewToFront:btnInstagram];
    
}

- (void)showGlobe {
    NSLog(@"showGlobe");
    [self bringSubviewToFront:globeView];
    
}

- (void)buttonPressed:(UIButton *)button {
    NSLog(@"Button Pressed: %@", button.currentTitle);
   
    NSString *btnTitle = [NSString stringWithString:button.currentTitle];
    
    if([btnTitle isEqualToString:@"donate"]){
        [self activateDonateDialog];
    } else if([btnTitle isEqualToString:@"facebook"]) {
        [self activateFacebookDialog];
    } else if([btnTitle isEqualToString:@"mail"]) {
        [self activateMailDialog];
    } else if([btnTitle isEqualToString:@"twitter"]) {
        [self activateTwitterDialog];
    } else if([btnTitle isEqualToString:@"instagram"]) {
        [self activateInstagramDialog];
    }
}

- (void)activateDonateDialog {
    NSLog(@"activateDonateDialog");
    
//    [m_pManager doSceneChange:[GSGlobe class]];
//    [m_pManager doSceneChange:[GSInfo class]];
    [m_pManager doSceneChange:[GSMantra class]];

    
}
- (void)activateFacebookDialog {
    NSLog(@"activateFacebookDialog");
    
    // http://soulwithmobiletechnology.blogspot.com/2012/07/tutorial-how-to-use-inbuilt.html
    // http://www.mobile.safilsunny.com/integrating-facebook-ios-6/
    // https://developer.apple.com/videos/play/wwdc2012-306/
    
    SLComposeViewController *fbController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [fbController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }};
        
        [fbController setInitialText:@"S T E M"];
//        [fbController addURL:[NSURL URLWithString:@"http://www.binarygizmo.com/portfolio"]];
        [fbController addImage:[UIImage imageNamed:@"share-screen.png"]];
        [fbController setCompletionHandler:completionHandler];
        [m_pManager presentViewController:fbController animated:YES completion:nil];
        
    }
    
}
- (void)activateMailDialog {
    NSLog(@"activateMailDialog");
    
    // http://www.codingexplorer.com/mfmailcomposeviewcontroller-send-email-in-your-apps/
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = m_pManager;
        [mail setSubject:@"S T E M"];
        [mail setMessageBody:@"Here is some main text in the email!" isHTML:NO];
        //        [mail setToRecipients:@[@"testingEmail@example.com"]];
        
        [m_pManager presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
    
}
- (void)activateTwitterDialog {
    NSLog(@"activateTwitterDialog");
    
    SLComposeViewController *twitterController=[SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewControllerCompletionHandler __block completionHandler=^(SLComposeViewControllerResult result){
            
            [twitterController dismissViewControllerAnimated:YES completion:nil];
            
            switch(result){
                case SLComposeViewControllerResultCancelled:
                default:
                {
                    NSLog(@"Cancelled.....");
                    
                }
                    break;
                case SLComposeViewControllerResultDone:
                {
                    NSLog(@"Posted....");
                }
                    break;
            }};
        
        [twitterController addImage:[UIImage imageNamed:@"share-screen.png"]];
        [twitterController setInitialText:@"S T E M"];
        [twitterController addURL:[NSURL URLWithString:@"http://www.binarygizmo.com/portfolio"]];
        [twitterController setCompletionHandler:completionHandler];
        [m_pManager presentViewController:twitterController animated:YES completion:nil];
    }
    else
    {
        NSLog(@"Twitter not available");
    }
    
}
- (void)activateInstagramDialog {
    NSLog(@"activateInstagramDialog");
    
    [m_pManager instagramOpenDocument];
    
//    [m_pManager doSceneChange:[GSGlobe class]];

}

- (void) update:(double)delta {
    //    NSLog(@"GSShare update");
    
    if(globeView) {
        
        if(breatheOut) {
            breatheScale +=.003;
            if(breatheScale > 1.1) {
                breatheOut = false;
            }
        } else {
            breatheScale -=.003;
            if(breatheScale < 1.0) {
                breatheOut = true;
            }
        }
        globeView.transform = CGAffineTransformScale(CGAffineTransformIdentity, breatheScale, breatheScale);
    }
    
    if(lensFlareLandscapeImgView) {
        lensFlareLandscapeImgView.transform = CGAffineTransformRotate(lensFlareLandscapeImgView.transform, 0.001);
    }
    
    if(lensFlarePortraitImgView) {
        lensFlarePortraitImgView.transform = CGAffineTransformRotate(lensFlarePortraitImgView.transform, 0.001);
    }
    
    
    if(orb) {
        [orb animateOrb:orb boundedByParent:self];
    }
    
}

- (void) render {
     //   NSLog(@"GSShare render");
    
    
    [self setNeedsDisplay]; //this sets up a deferred call to drawRect.
}

- (void)drawRect:(CGRect)rect {
    //    NSLog(@"GSShare drawRect");
    
//    [self showFPS];
}
@end
