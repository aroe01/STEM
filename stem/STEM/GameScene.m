//
//  GameScene.m
//  Earth 1
//
//  Created by Ian on 9/14/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import "GameScene.h"

@interface GameScene ()

@end

@implementation GameScene

-(id) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager {
    
    NSLog(@"Initializing GameState");
    
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        m_pManager = manager;
        self.userInteractionEnabled = true;
    }
    return self;
}

- (void) update:(double)delta {
    
}

- (void) render {
    
}

- (void)drawRect:(CGRect)rect {
    
}

//-(void) updateBounds:(CGSize)size withOrientation:(MyViewOrientation)orientation {
-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)scale {
    
}

- (void)showFPS {
    
    //fps display from page 76 of iPhone Game Development
    int FPS = [m_pManager getFramesPerSecond];
    NSString* strFPS = [NSString stringWithFormat:@"%d", FPS];
    
    UIFont* font = [UIFont fontWithName:@"Arial" size:72];
    UIColor* textColor = [UIColor redColor];
    NSDictionary* stringAttrs = @{ NSFontAttributeName : font, NSForegroundColorAttributeName : textColor };
    NSAttributedString* attrStr = [[NSAttributedString alloc] initWithString: strFPS attributes:stringAttrs];
    [attrStr drawAtPoint:CGPointMake(10.f, 100.f)];
    
}


@end
