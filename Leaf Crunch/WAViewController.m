//
//  WAViewController.m
//  Leaf Crunch
//
//  Created by Daniel Ho on 1/21/13.
//  Copyright (c) 2013 Daniel Ho. All rights reserved.
//

#import "WAViewController.h"
#import "Util.h"
#import "GroundView.h"

@interface WAViewController ()

@end

@implementation WAViewController

- (id)init
{
    if (self = [super init])
    {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    CGSize screenSize = [Util screenSize];
    CGRect screenFrame = CGRectMake(0, 0, screenSize.width, screenSize.height);
    self.view = [[[GroundView alloc] initWithFrame:screenFrame] autorelease];
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake)
    {
        GroundView* groundView = (GroundView*)self.view;
        [groundView applyShake];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// singleton pattern
static WAViewController* _sharedInstance = nil;

+ (WAViewController*)sharedInstance
{
	if(!_sharedInstance)
    {
        _sharedInstance = [[self alloc] init];
	}
    
	return _sharedInstance;
}

@end
