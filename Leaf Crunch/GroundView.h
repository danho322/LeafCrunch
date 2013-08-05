//
//  GroundView.h
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Util.h"

#define LEAF_COUNT              10
#define UPDATE_TICK_DURATION     0.01f
#define STOP_THRESHOLD          .1
#define VELOCITY_UPDATE_SCALE   .96
#define UPDATE_DELAY_THRESHOLD  2
#define COLLISION_SCALE         .6
#define WIND_MAX_WAIT           5
#define WIND_MAX_VELOCITY       1
#define WIND_INCREMENT          .05

@class LeafView;

@interface GroundView : UIView
{
    CADisplayLink* _displayLink;
    NSMutableArray* _leafArray;
    NSMutableArray* _leavesToRemove;
    
    CGPoint _maxWind;
    CGPoint _currentWind;
}

- (void)detectCollisionForLeafView:(LeafView*)leaf;
- (void)applyShake;

@end
