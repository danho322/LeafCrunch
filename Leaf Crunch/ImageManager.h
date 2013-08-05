//
//  ImageManager.h
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ImageManager : NSObject
{
    NSMutableDictionary* _imageCache;
}

- (UIImage*)imageNamed:(NSString*)imageName;
+ (ImageManager*)sharedInstance;

@end
