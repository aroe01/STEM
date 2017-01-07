//
//  BGAnimatingButton.m
//  Earth Mantra 2
//
//  Created by Ian on 4/30/16.
//  Copyright © 2016 Binary Gizmo. All rights reserved.
//

#import "BGAnimatingButton.h"

@implementation BGAnimatingButton

#pragma mark - UIButton Overrides

+ (BGAnimatingButton *)buttonWithType:(UIButtonType)type
{
    return [super buttonWithType:UIButtonTypeCustom];
}

- (void)setHighlighted:(BOOL)highlighted
{
    NSLog(@"BGAnimatingButton:setHighlighted");
    
    [self setNeedsDisplay];
    [super setHighlighted:highlighted];
}

#pragma mark - Touch event overrides

- (void)drawRect:(CGRect)rect
{
    NSLog(@"BGAnimatingButton:drawRect");
    
    
    // General Declarations
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Color Declarations
    UIColor *borderColor = [UIColor colorWithRed:0.77f green:0.43f blue:0.00f alpha:1.00f];
    UIColor *topColor = [UIColor colorWithRed:0.94f green:0.82f blue:0.52f alpha:1.00f];
    UIColor *bottomColor = [UIColor colorWithRed:0.91f green:0.55f blue:0.00f alpha:1.00f];
    UIColor *innerGlow = [UIColor colorWithWhite:1.0 alpha:0.5];
    
    // Gradient Declarations
    NSArray *gradientColors = (@[
                                 (id)topColor.CGColor,
                                 (id)bottomColor.CGColor
                                 ]);
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(gradientColors), NULL);
    
    NSArray *highlightedGradientColors = (@[
                                            (id)bottomColor.CGColor,
                                            (id)topColor.CGColor
                                            ]);
    
    CGGradientRef highlightedGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)(highlightedGradientColors), NULL);
    
    
    // Draw rounded rectangle bezier path
    UIBezierPath *roundedRectanglePath = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(0, 0, 280, 37) cornerRadius: 5];
    // Use the bezier as a clipping path
    [roundedRectanglePath addClip];
    
    // Use one of the two gradients depending on the state of the button
    CGGradientRef background = self.highlighted? highlightedGradient : gradient;
    
    // Draw gradient within the path
    CGContextDrawLinearGradient(context, background, CGPointMake(140, 0), CGPointMake(140, 37), 0);
    
    // Draw border
    [borderColor setStroke];
    roundedRectanglePath.lineWidth = 2;
    [roundedRectanglePath stroke];
    
    // Draw Inner Glow
    UIBezierPath *innerGlowRect = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(1.5, 1.5, 277, 34) cornerRadius: 4];
    [innerGlow setStroke];
    innerGlowRect.lineWidth = 1;
    [innerGlowRect stroke];
    
    // Cleanup
    CGGradientRelease(gradient);
    CGGradientRelease(highlightedGradient);
    CGColorSpaceRelease(colorSpace);
}

@end
