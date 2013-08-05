//
//  LeafView.h
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LeafView : UIView
{
    id _closeDelegate;
    SEL _closeSelector;
    
    UIImageView* _imageView;
    CGPoint _lastCenter;
    CGPoint _lastVelocity;
    CGPoint _velocity;
    CGPoint _currentPoint;
    NSInteger _updateDelayCounter;
    BOOL _isTouched;
    
    BOOL _isCollided;
}

@property (nonatomic, assign) id closeDelegate;
@property (nonatomic, assign) SEL closeSelector;
@property CGPoint velocity;
@property (nonatomic, retain) UIImageView* imageView;
@property BOOL isCollided;

- (void)playFallAnimation;
- (CGFloat)timeUntilStop;
- (void)setInitialCenter:(CGPoint)center;
- (void)updateMovement;
- (void)applyWindVelocity:(CGPoint)wind;
+ (void)runSpinAnimationOnView:(LeafView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat;

@end
