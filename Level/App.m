/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "MenuView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Gestures.h>
#import <UIKit/UIView-Animation.h>

@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	float bx;
	float by;

	// check if laying flat on the surface or along an edge
	if( fabs(z) >= 0.30 ) {
		bx = 160 + (160*(x/0.5));
		by = 240 + (240*(y/0.5));
	} else {
		if( fabs(x) <= 0.3 ) {
			bx = 160 + (160*(x/0.5));
			by = y < 0? 42.5: 437.5;
		} else {
			bx = x < 0? 42.5: 277.5;
			by = 240 + (240*(y/0.5));
		}
	}

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 3];
	[UIView setAnimationDuration:0.1];
	[bubble setOrigin: CGPointMake(bx-42.5, by-42.5)];
	[UIView endAnimations];
}

-(void)showLevel
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	UIImageView *lines = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"lines.png"]] autorelease];
	bubble = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"bubble.png"]];

	[bg addSubview: bubble];
	[bg addSubview: lines];
	[window setContentView: bg];
}

-(void)showDigg
{
	// :-)
	[self openURL: [NSURL URLWithString: @"http://digg.com/apple/iApp_a_Day"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Level" body: nil] autorelease];
	[menu addButtonWithTitle: @"Continue" target: self action: @selector(showLevel)];
	[menu addButtonWithTitle: @"Digg iApp-a-Day!" target: self action: @selector(showDigg)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
        SplashView *s = [[[SplashView alloc] initWithName: @"Level" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
        [s continueTarget: self action: @selector(showMenu)];
        [window setContentView: s];
}

-(void)dealloc
{
	[bubble release];
	[window release];
	[super dealloc];
}

- (void) applicationDidFinishLaunching: (id) unused
{
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
