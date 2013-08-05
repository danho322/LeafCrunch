//
//  LeafView.m
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "LeafView.h"
#import "LeafData.h"
#import "Util.h"
#import "GroundView.h"
#import <math.h>

@implementation LeafView
@synthesize closeDelegate = _closeDelegate;
@synthesize closeSelector = _closeSelector;
@synthesize imageView = _imageView;
@synthesize isCollided = _isCollided;

- (void)dealloc
{
    self.imageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _updateDelayCounter = 0;
        NSArray* leafImages = [LeafData randomLeafImages];
        self.imageView = [[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)] autorelease];
        [_imageView setAnimationImages:leafImages];
        [_imageView setImage:[leafImages objectAtIndex:0]];
        [_imageView setAnimationDuration:.3];
        [_imageView setAnimationRepeatCount:1];
        [_imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self addSubview:_imageView];

        _lastVelocity = CGPointZero;
        _velocity = CGPointZero;
        
        _isTouched = NO;
        _lastCenter = self.center;
        
        _imageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(arc4random() % 360));

        _isCollided = NO;
       
        UITapGestureRecognizer* tapGesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(leafTapped:)] autorelease];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)playFallAnimation
{
    CGFloat duration = 1;
    [self setAlpha:0];
    [self setTransform:CGAffineTransformMakeScale(5, 5)];
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveLinear
                     animations:^(void){
                         [self setAlpha:1];
                         [self setTransform:CGAffineTransformIdentity];
                     }
                     completion:^(BOOL finished){
                         
                     }];
    
    [LeafView runSpinAnimationOnView:self duration:duration rotations:((arc4random() % 20) - 10) / 10.f repeat:NO];
}

- (void)setInitialCenter:(CGPoint)center
{
    self.center = center;
    _lastCenter = center;
}

-(void)leafTapped:(id)sender
{
    [_imageView startAnimating];
    
    [self performSelector:@selector(fadeAndDisappear) withObject:nil afterDelay:_imageView.animationDuration];
}

- (void)fadeAndDisappear
{
    [UIView animateWithDuration:.5 animations:^(void)
    {
        [self setAlpha:0];
    }
    completion:^(BOOL finished)
    {
        if (finished)
        {
            [_closeDelegate performSelector:_closeSelector withObject:self];
        }
    }];
}

- (void)touchesBegan:(NSSet*)touches withEvent:(UIEvent*)event
{
    _isTouched = YES;
    // When a touch starts, get the current location in the view
    _currentPoint = [[touches anyObject] locationInView:self];
}

- (void)touchesMoved:(NSSet*)touches withEvent:(UIEvent*)event
{
    // Get active location upon move
    CGPoint activePoint = [[touches anyObject] locationInView:self];
    
    // Determine new point based on where the touch is now located
    CGPoint newPoint = CGPointMake(self.center.x + (activePoint.x - _currentPoint.x),
                                   self.center.y + (activePoint.y - _currentPoint.y));
    
    //--------------------------------------------------------
    // Make sure we stay within the bounds of the parent view
    //--------------------------------------------------------
    float midPointX = CGRectGetMidX(self.bounds);
    // If too far right...
    if (newPoint.x > self.superview.bounds.size.width  - midPointX)
        newPoint.x = self.superview.bounds.size.width - midPointX;
    else if (newPoint.x < midPointX)  // If too far left...
        newPoint.x = midPointX;
    
    float midPointY = CGRectGetMidY(self.bounds);
    // If too far down...
    if (newPoint.y > self.superview.bounds.size.height  - midPointY)
        newPoint.y = self.superview.bounds.size.height - midPointY;
    else if (newPoint.y < midPointY)  // If too far up...
        newPoint.y = midPointY;
    
    // Set new center location
    self.center = newPoint;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isTouched = NO;
    
    if (fabs(_velocity.x) + fabs(_velocity.y) > 1)
    {
        //CGFloat duration = .5f + (arc4random() % 20) / 10.f;
        CGFloat rotations = (arc4random() % 10) / 10.f;
        [LeafView runSpinAnimationOnView:self duration:[self timeUntilStop] rotations:rotations repeat:NO];
    }
}

- (CGFloat)timeUntilStop
{
    CGFloat timeLeft = 0;
    // Calculate how much time until leaf stops moving based on velocity
    if (!_isTouched && !CGPointEqualToPoint(_velocity, CGPointZero))
    {
        CGFloat logStop = log(STOP_THRESHOLD);
        CGFloat logScale = log(VELOCITY_UPDATE_SCALE);
        CGFloat logVelX = log(fabs(_velocity.x));
        CGFloat logVelY = log(fabs(_velocity.y));
        CGFloat expX = (logStop - logVelX) / logScale;
        CGFloat expY = (logStop - logVelY) / logScale;
        timeLeft = MAX(expX, expY) * UPDATE_TICK_DURATION;
    }
    return timeLeft;
}

- (void)updateMovement
{
    CGPoint center = self.center;
    
    _lastVelocity = _velocity;
    
    if (_isTouched)
    {
        _velocity = CGPointMake(center.x - _lastCenter.x, center.y - _lastCenter.y);
        
        if (CGPointEqualToPoint(_velocity, CGPointZero))
        {
            _velocity = _lastVelocity;
        }
    }
    else
    {
        if (CGPointEqualToPoint(_velocity, CGPointZero))
        {
            _isCollided = NO;
            return;
        }
        
        self.center = CGPointMake(_lastCenter.x + _velocity.x, _lastCenter.y + _velocity.y);
        
        if (_updateDelayCounter < UPDATE_DELAY_THRESHOLD)
        {
            CGFloat stopThreshold = STOP_THRESHOLD;
            CGFloat velocityScale = VELOCITY_UPDATE_SCALE;
            
            _velocity.x = _velocity.x * velocityScale;
            _velocity.y = _velocity.y * velocityScale;
            
            if (fabs(_velocity.x) < stopThreshold)
                _velocity.x = 0;
            if (fabs(_velocity.y) < stopThreshold)
                _velocity.y = 0;
            _updateDelayCounter++;
        }
        else
        {
            _updateDelayCounter = 0;
        }
        
        if (!_isCollided && !CGPointEqualToPoint(_velocity, CGPointZero))
        {
            GroundView* groundView = (GroundView*)[self superview];
            [groundView detectCollisionForLeafView:self];
        }
    
        if ([self isOutOfBounds])
        {
            [_closeDelegate performSelector:_closeSelector withObject:self];
        }
    }
    _lastCenter = self.center;
}

- (BOOL)isOutOfBounds
{
    CGSize screenSize = [Util screenSize];
    return (self.frame.origin.x < -self.frame.size.width ||
        self.frame.origin.x > screenSize.width ||
        self.frame.origin.y < -self.frame.size.height ||
        self.frame.origin.y > screenSize.height);
}

- (void)applyWindVelocity:(CGPoint)wind
{
    CGFloat scale = [LeafData leafScaleFromMax:self.frame.size];
    _velocity = CGPointMake(_velocity.x + wind.x * scale, _velocity.y + wind.y * scale);
}

+ (void)runSpinAnimationOnView:(LeafView*)view duration:(CGFloat)duration rotations:(CGFloat)rotations repeat:(float)repeat
{
    [UIView animateWithDuration:duration
                          delay:0
                        options:UIViewAnimationCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         view.imageView.transform = CGAffineTransformMakeRotation(DegreesToRadians(rotations * 360));
                     }
                     completion:nil];
    
}


@end
