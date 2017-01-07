//
//  OrbView.m
//  STEM
//
//  Created by Ian on 11/12/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "OrbView.h"

static const int NUM_ORB_FRAMES = 240;
static const int FIRST_ORB_FRAME_ORDINAL = 0;
NSString static *const ORB_FILENAME = @"gb_15fps_%05d.png";

#define DEGREES_TO_RADIANS(angle) (angle/180.0*M_PI)

@implementation OrbView {
    
    float angle;
    int orbFrameCnt;
    UIImageView *animationImageView;
    BOOL orbAwake;
    
    NSMutableArray *images;

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

/*
 This method gets called when the view's superview changes, even when it's removed from it's superview.
 
 */
- (void)didMoveToSuperview {
    
    [super didMoveToSuperview];
    
    // Initialize view only if it is being added to it's superview
    if(self.superview)
    {
        angle = 0;
        orbFrameCnt= 0;
        orbAwake = NO;

        images = [[NSMutableArray alloc] init];
        
        
/*
        NSMutableArray *images = [[NSMutableArray alloc] init];
        // Added to superview
        for (unsigned int ii=0;ii<NUM_ORB_FRAMES;ii++)
        {
            NSString *img = [NSString stringWithFormat:ORB_FILENAME, ii+FIRST_ORB_FRAME_ORDINAL];
            [images addObject:[UIImage imageNamed:img]];
        }
        

        // Normal Animation
        UIImageView *animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        animationImageView.animationImages = images;
        animationImageView.animationDuration = 15;
        
        [self addSubview:animationImageView];
        [animationImageView startAnimating];
*/
  

        animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        NSString *img = [NSString stringWithFormat:ORB_FILENAME, FIRST_ORB_FRAME_ORDINAL];
        UIImage *image = [UIImage imageNamed:img];
        [animationImageView setImage:image];
        [self addSubview:animationImageView];

        
        animationImageView.alpha = 1.0;
        angle = 90;
        [self wakeUpWithDelay:2.0];
        
        
    } else {
        
        // Removed to superview
    }
}

-(void) animateOrb:(UIView *) oview boundedByParent:(UIView *)parent {
    
    // http://stackoverflow.com/questions/17765841/draw-moving-circles
    
    float w = (parent.bounds.size.width)/2;
    float h = (parent.bounds.size.width)/2;
    
    //  float w = (320)/2;
    //  float h = (320)/2;
    
    float x = w + w * cos(angle * M_PI / 180);
    float y = h + h * sin(angle * M_PI / 180);
    
    CGRect br = CGRectMake(((parent.bounds.size.width/2)) - (x/2) - 20, (parent.bounds.size.height/2)-(y/2), 200, 200);
    [oview setFrame:br];
    
    angle+=0.5;
//    NSLog(@"Angle: %f", angle);
    if (angle > 360) {
        angle = 0;
    }


    orbFrameCnt += 1;
    orbFrameCnt = orbFrameCnt % NUM_ORB_FRAMES;
    
    UIImage *image;
    
    if(images.count < NUM_ORB_FRAMES) {
    
        NSString *img = [NSString stringWithFormat:ORB_FILENAME, orbFrameCnt+FIRST_ORB_FRAME_ORDINAL];
        image = [UIImage imageNamed:img];
        [images addObject:image];
    
    } else {
        
        image = images[orbFrameCnt];
        NSLog(@"Orb frame cnt: %d", orbFrameCnt);
        NSLog(@"Orb frame cnt: %d", images.count);
    }
    [animationImageView setImage:image];
    
        
}

-(void) wakeUpWithDelay: (float)delay {
    
    if(!orbAwake) {
        
        NSLog(@"ORB AWAKE: %hhd", orbAwake);
        angle = 90;
        
        [UIView animateWithDuration:0.5
                              delay: delay
                            options: UIViewAnimationOptionCurveLinear
                         animations:^{
                             animationImageView.alpha = 1.0;
                         }
                         completion:^(BOOL finished){
                             NSLog(@"Done!");
                             animationImageView.alpha = 1.0;
                             orbAwake = YES;
                             
                             
                             [UIView animateWithDuration:1.5
                                                   delay: 5.0
                                                 options: UIViewAnimationOptionCurveEaseIn
                                              animations:^{
                                                  animationImageView.alpha = 0.0;
                                              }
                                              completion:^(BOOL finished){
                                                  NSLog(@"Done!");
                                                  orbAwake = NO;
                                                  NSLog(@"ORB AWAKE: %hhd", orbAwake);

                                              }];
                             
                             
                         }];
    }
}

-(BOOL) isAwake {
    return orbAwake;
}

@end
