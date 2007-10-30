/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Gestures.h>
#import <UIKit/UIView-Animation.h>

@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	xTilt = x;
	yTilt = y;
	zTilt = z;
}

- (void) thing
{
	if( fabsf(zTilt) < 0.4 ) {
		[UIView beginAnimations:nil];
		[UIView setAnimationCurve:3];
		[UIView setAnimationDuration:0.15];

		if( yTilt <= 0 ) {
			[img setTransform: CGAffineTransformMakeRotation(M_PI*xTilt)];
		} else {
			[img setTransform: CGAffineTransformMakeRotation(M_PI-(M_PI*xTilt))];
		}

		[UIView endAnimations];
	}

	[self performSelector:@selector(thing) withObject:self afterDelay:0.15];
}

-(void)showPumpkin
{
	UIView *v = [[[UIView alloc] init] autorelease];
	img = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"pumpkin.png"]] autorelease];
	[img setOrigin: CGPointMake(10,106.5)];
	[v addSubview: img];
	[window setContentView: v];
	[self thing];
}

-(void)showSplash
{
        SplashView *s = [[[SplashView alloc] initWithName: @"Pumpkin" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
        [s continueTarget: self action: @selector(showPumpkin)];
        [window setContentView: s];
}

-(void)dealloc
{
	[window release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching: (id) unused
{
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	frame.origin.y = 0;

	window = [[UIWindow alloc] initWithContentRect: frame];
	float bgColor[] = { 0, 0, 0, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	xTilt = yTilt = 0;

	[self showSplash];
}

@end
