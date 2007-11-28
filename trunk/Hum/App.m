/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "MenuView.h"
#import "TonePlayer.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Gestures.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UISliderControl.h>

@implementation App

-(void)sliderChanged: (UISliderControl*)slider
{
	float f = (200.0f + (200.0f * [slider tag])) * [slider value];
	[[tones objectAtIndex: [slider tag]] setFrequency: f];
}

-(void)showControls
{
	[player play];
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];

	#define SLIDER(x) { \
		UISliderControl *s = [[[UISliderControl alloc] initWithFrame: CGRectMake(0,25+(x * 42),[window bounds].size.width,30)] autorelease]; \
		[s setTag: x]; \
		[s addTarget: self action: @selector(sliderChanged:) forEvents: (1<<2)]; \
		[s addTarget: self action: @selector(sliderChanged:) forEvents: (1<<3)]; \
		[s addTarget: self action: @selector(sliderChanged:) forEvents: (1<<6)]; \
		[v addSubview: s]; \
	}

	SLIDER(0);
	SLIDER(1);
	SLIDER(2);
	SLIDER(3);
	SLIDER(4);
	SLIDER(5);
	SLIDER(6);
	SLIDER(7);
	SLIDER(8);
	SLIDER(9);

	[window setContentView: v];
}

-(void)showBlog
{
	[self openURL: [NSURL URLWithString: @"http://blog.bigzaphod.org/"]];
}

-(void)showDonate
{
	[self openURL: [NSURL URLWithString: @"http://www.iappaday.com/donate.html"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Hum..." body: nil] autorelease];
	[menu addButtonWithTitle: @"Start Humming" target: self action: @selector(showControls)];
	[menu addButtonWithTitle: @"Visit iApp-a-Day Blog" target: self action: @selector(showBlog)];
	[menu addButtonWithTitle: @"Donate" target: self action: @selector(showDonate)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Hum" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

-(void)dealloc
{
	[player release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	player = [[TonePlayer alloc] init];

	tones = [[NSArray arrayWithObjects:
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
		[player addTone: [Tone toneWithFrequency: 0]],
	nil] retain];

	[self showSplash];
}

@end
