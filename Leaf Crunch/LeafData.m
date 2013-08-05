//
//  LeafData.m
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "LeafData.h"
#import "Util.h"
#import "ImageManager.h"

#define MIN_LEAFSIZE        IPHONE_IPAD(CGSizeMake(40,40), CGSizeMake(40,40))
#define MAX_LEAFSIZE        IPHONE_IPAD(CGSizeMake(120,120), CGSizeMake(120,120))

@implementation LeafData

+ (CGSize)randomLeafSize
{
    CGSize minSize = MIN_LEAFSIZE;
    CGSize maxSize = MAX_LEAFSIZE;
    
    NSInteger rand = arc4random() % (NSInteger)(maxSize.width - minSize.width);
    CGSize randSize = CGSizeMake(minSize.width + rand, minSize.height + rand);
    return randSize;
}

+ (CGFloat)leafScaleFromMax:(CGSize)leafSize
{
    return (leafSize.width - IPHONE_IPAD(10, 20)) / MAX_LEAFSIZE.width;
}

+ (NSArray*)randomLeafImages
{
    return [NSArray arrayWithObjects:[[ImageManager sharedInstance] imageNamed:@"leaf.png"], [[ImageManager sharedInstance] imageNamed:@"leaf2.png"], nil];
    
}

@end
