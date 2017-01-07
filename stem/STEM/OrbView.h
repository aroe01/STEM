//
//  OrbView.h
//  STEM
//
//  Created by Ian on 11/12/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrbView : UIView

-(void) animateOrb:(UIView *) view boundedByParent:(UIView *)parent;
-(void) wakeUpWithDelay: (float)delay;
-(BOOL) isAwake;

@end
