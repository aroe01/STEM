//
//  GameScene.h
//  Earth 1
//
//  Created by Ian on 9/14/15.
//  Copyright (c) 2015 Binary Gizmo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameSceneManager.h"


@interface GameScene : UIView {
    GameSceneManager* m_pManager;
}

-(id) initWithFrame:(CGRect)frame gameSceneManager:(GameSceneManager*)manager;

-(void) render;
-(void) update:(double)delta;
- (void)showFPS;
//-(void) updateBounds:(CGSize)size withOrientation:(MyViewOrientation)orientation;
-(void) updateBounds:(CGSize)size orientation:(MyViewOrientation)orientation scale:(CGFloat)orientation;


@end
