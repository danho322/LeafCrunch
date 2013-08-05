//
//  ImageManager.m
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "ImageManager.h"

@interface ImageManager()
@property (nonatomic, retain) NSMutableDictionary* imageCache;
@end

@implementation ImageManager
@synthesize imageCache = _imageCache;

- (void)dealloc
{
    self.imageCache = nil;
    [super dealloc];
}

- (id)init
{
    if (self = [super init])
    {
        self.imageCache = [NSMutableDictionary dictionary];
    }
    return self;
}

- (UIImage*)imageNamed:(NSString*)imageName
{
    UIImage* image = [_imageCache objectForKey:imageName];
    if (!image)
    {
        image = [UIImage imageNamed:imageName];
        [_imageCache setObject:image forKey:imageName];
    }
    return image;
}

// singleton pattern
static ImageManager* _sharedInstance = nil;

+ (ImageManager*)sharedInstance
{
	if(!_sharedInstance)
    {
        _sharedInstance = [[self alloc] init];
	}
    
	return _sharedInstance;
}

@end
