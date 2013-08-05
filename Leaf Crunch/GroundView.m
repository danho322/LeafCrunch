//
//  GroundView.m
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "GroundView.h"
#import "LeafView.h"
#import "LeafData.h"
#import <QuartzCore/QuartzCore.h>

@interface GroundView()
@property (nonatomic, retain) CADisplayLink* displayLink;
@property (nonatomic, retain) NSMutableArray* leafArray;
@property (nonatomic, retain) NSMutableArray* leavesToRemove;
@end

@implementation GroundView
@synthesize displayLink = _displayLink;
@synthesize leafArray = _leafArray;

- (void)dealloc
{
    self.displayLink = nil;
    self.leafArray = nil;
    self.leavesToRemove = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        NSInteger leafCount = LEAF_COUNT;
        self.leafArray = [NSMutableArray arrayWithCapacity:leafCount];
        self.leavesToRemove = [NSMutableArray arrayWithCapacity:leafCount];
        
        _maxWind = CGPointZero;
        _currentWind = CGPointZero;
        
        UIButton* windButton = [[[UIButton alloc] initWithFrame:CGRectMake(0, 0, 50, 50)] autorelease];
        [windButton setBackgroundColor:[UIColor redColor]];
        [windButton addTarget:self action:@selector(generateWind) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:windButton];
        
        UIButton* shakeButton = [[[UIButton alloc] initWithFrame:CGRectMake(50, 0, 50, 50)] autorelease];
        [shakeButton setBackgroundColor:[UIColor purpleColor]];
        [shakeButton addTarget:self action:@selector(applyShake) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:shakeButton];
        
        [self applyShake];
        
//        [self performSelector:@selector(applyWind) withObject:nil afterDelay:(arc4random() % WIND_MAX_WAIT)];
    }
    
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(update:)];
    [_displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    return self;
}

+ (CGPoint)randomPointInView
{
    CGSize screenSize = [Util screenSize];
    return CGPointMake(floor(arc4random() % (NSInteger)screenSize.width), floor(arc4random() % (NSInteger)screenSize.height));
}

- (void)update:(CADisplayLink*)sender
{
    //CFTimeInterval dt = sender.duration;
    
    [self applyWind];
    
    for (LeafView* leaf in _leafArray)
    {
        [leaf applyWindVelocity:_currentWind];
        [leaf updateMovement];
    }
    
    for (LeafView* leaf in _leavesToRemove)
    {
        [_leafArray removeObject:leaf];
    }
    [_leavesToRemove removeAllObjects];
}

- (void)applyWind
{
    if (!CGPointEqualToPoint(_maxWind, CGPointZero))
    {
        if (_maxWind.x > 0)
            _currentWind.x += WIND_INCREMENT;
        else if (_maxWind.x < 0)
            _currentWind.x -= WIND_INCREMENT;
        if (_maxWind.y > 0)
            _currentWind.y += WIND_INCREMENT;
        else if (_maxWind.y < 0)
            _currentWind.y -= WIND_INCREMENT;
        
        if (fabs(_currentWind.x) > fabs(_maxWind.x))
        {
            _maxWind.x = 0;
        }
        if (fabs(_currentWind.y) > fabs(_maxWind.y))
        {
            _maxWind.y = 0;
        }
    }
    else if (!CGPointEqualToPoint(_currentWind, CGPointZero))
    {
        if (_currentWind.x > 0)
        {
            _currentWind.x = _currentWind.x - WIND_INCREMENT;
            if (_currentWind.x < 0)
                _currentWind.x = 0;
        }
        else
        {
            _currentWind.x = _currentWind.x + WIND_INCREMENT;
            if (_currentWind.x > 0)
                _currentWind.x = 0;
        }
        if (_currentWind.y > 0)
        {
            _currentWind.y = _currentWind.y - WIND_INCREMENT;
            if (_currentWind.y < 0)
                _currentWind.y = 0;
        }
        else
        {
            _currentWind.y = _currentWind.y + WIND_INCREMENT;
            if (_currentWind.y > 0)
                _currentWind.y = 0;
        }
    }
    NSLog(@"wind %f,%f", _currentWind.x, _currentWind.y);
}

- (void)generateWind
{
    CGFloat minVal = -WIND_MAX_VELOCITY;
    CGFloat maxVal = WIND_MAX_VELOCITY;
    NSInteger delta = maxVal - minVal;
    NSInteger x = minVal + (arc4random() % delta);
    NSInteger y = minVal + (arc4random() % delta);
    _maxWind = CGPointMake(x, y);
    NSLog(@"max %f,%f", _maxWind.x,_maxWind.y);
//    for (LeafView* leaf in _leafArray)
//    {
//        //CGFloat duration = .5f + (arc4random() % 20) / 10.f;
//        CGFloat rotations = (arc4random() % 10) / 10.f;
//        [leaf applyWindVelocity:windVelocity];
//        [LeafView runSpinAnimationOnView:leaf duration:[leaf timeUntilStop] rotations:rotations repeat:NO];
//    }
//    [self performSelector:@selector(applyWind) withObject:nil afterDelay:(arc4random() % WIND_MAX_WAIT)];
}

- (void)applyShake
{
    NSInteger leafCount = LEAF_COUNT;
    for (int i = 0; i < leafCount; i++)
    {
        CGSize randomSize = [LeafData randomLeafSize];
        LeafView* leaf = [[[LeafView alloc] initWithFrame:CGRectMake(0, 0, randomSize.width, randomSize.height)] autorelease];
        leaf.closeDelegate = self;
        leaf.closeSelector = @selector(removeLeaf:);
        [self addSubview:leaf];
        [leaf setInitialCenter:[GroundView randomPointInView]];
        [leaf playFallAnimation];
        [_leafArray addObject:leaf];
    }
}

- (void)removeLeaf:(LeafView*)leafView
{
    [leafView removeFromSuperview];
    [_leavesToRemove addObject:leafView];
}

- (void)detectCollisionForLeafView:(LeafView*)leaf
{
    NSInteger buffer = IPHONE_IPAD(10, 20);
    CGFloat collisionScale = COLLISION_SCALE;
    CGRect leafFrame = CGRectMake(leaf.frame.origin.x + buffer,
                                  leaf.frame.origin.y + buffer,
                                  leaf.frame.size.width - buffer,
                                  leaf.frame.size.height - buffer);
    for (LeafView* otherLeaf in _leafArray)
    {
        if (![leaf isEqual:otherLeaf] && !otherLeaf.isCollided)
        {
            CGRect otherLeafFrame = CGRectMake(otherLeaf.frame.origin.x + buffer,
                                          otherLeaf.frame.origin.y + buffer,
                                          otherLeaf.frame.size.width - buffer,
                                          otherLeaf.frame.size.height - buffer);
            if (CGRectIntersectsRect(leafFrame, otherLeafFrame))
            {
                otherLeaf.velocity = CGPointMake(otherLeaf.center.x - leaf.center.x, otherLeaf.center.y - leaf.center.y);
                CGFloat scale = (fabs(leaf.velocity.x) + fabs(leaf.velocity.y)) / (fabs(otherLeaf.velocity.x) + fabs(otherLeaf.velocity.y)) * collisionScale;
                otherLeaf.velocity = CGPointMake(otherLeaf.velocity.x * scale, otherLeaf.velocity.y * scale);
                otherLeaf.isCollided = YES;
                
                leaf.velocity = CGPointMake(leaf.velocity.x * collisionScale, leaf.velocity.y * collisionScale);
            }
        }
    }
}

@end
