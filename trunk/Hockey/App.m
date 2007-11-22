/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "GameView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController.h>

@implementation App

-(void)startGame
{
	GameView *game = [[[GameView alloc] init] autorelease];
	[window setContentView: game];
}

-(void)showSplash
{
	SplashView *s = [[SplashView alloc] initWithName: @"Hockey" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: @"Krzysztof Jankowski <w84death@gmail.com>"];
	[s continueTarget: self action: @selector(startGame)];
	[window setContentView: s];
}

- (void)applicationDidFinishLaunching: (id) unused
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
