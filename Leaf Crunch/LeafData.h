//
//  LeafData.h
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeafData : NSObject

+ (CGSize)randomLeafSize;
+ (NSArray*)randomLeafImages;
+ (CGFloat)leafScaleFromMax:(CGSize)leafSize;

@end
