//
//  Util.h
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

#define IPHONE_IPAD(iPhoneExpression, iPadExpression)    ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)?(iPhoneExpression):(iPadExpression))
#define DegreesToRadians(x) ((x) * M_PI / 180.0)

@interface Util : NSObject

+ (CGSize)screenSize;

@end
