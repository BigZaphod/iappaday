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

@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	if( !beat && y > 0 ) {
		[player addTone: tone];
		beat = YES;
		beatAt = y;
	} else if( beat && y+0.1 < beatAt ) {
		beat = NO;
	}
}

-(void)setTone: (CGPoint)p
{
	[tone release];
	tone = [[Tone toneWithFrequency: 80+(155.0f * (p.y / 480.0f)) attack: 0.01 decay: 0.005 + (0.1 * (p.x / 320.0f)) sustain: 0.7 release: 0.005 + (0.2 * (p.x / 320.0f)) lifespan: 0.08] retain];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseDragged:(struct __GSEvent *)e
{
	[self setTone: GSEventGetLocationInWindow(e)];
}
-(void)mouseDown:(struct __GSEvent *)e
{
	[self setTone: GSEventGetLocationInWindow(e)];
}
-(void)mouseUp:(struct __GSEvent *)e
{
	[self setTone: GSEventGetLocationInWindow(e)];
}

-(void)showDrum
{
	player = [[TonePlayer alloc] init];
	[player play];
	tone = [[Tone toneWithFrequency: 210 attack: 0.01 decay: 0.01 sustain: 0.7 release: 0.01 lifespan: 0.08] retain];
	UIImageView *v = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"Default.png"]] autorelease];
	[window setContentView: v];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Drum" body: @"To play the drum, place your thumb on the screen and wave the phone or iPod as if it were a drumstick. Slide your thumb to influence the sound of the beat."] autorelease];
	[menu addButtonWithTitle: @"Start Drumming" target: self action: @selector(showDrum)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showBlog
{
        [self openURL: [NSURL URLWithString: @"http://blog.bigzaphod.org/"]];
}

-(void)showDonate
{
        [self openURL: [NSURL URLWithString: @"http://www.iappaday.com/donate.html"]];
}

-(void)showSource
{
        [self openURL: [NSURL URLWithString: @"http://code.google.com/p/iappaday/"]];
}

-(void)showSpecialMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Thanks for all the fish..." body: @"This is the end of my iApp-a-Day project. I hope my hard work this month has been enjoyable for you! See you around. :)"] autorelease];
	[menu addButtonWithTitle: @"Continue" target: self action: @selector(showMenu)];
	[menu addButtonWithTitle: @"Donate" target: self action: @selector(showDonate)];
	[menu addButtonWithTitle: @"My Blog" target: self action: @selector(showBlog)];
	[menu addButtonWithTitle: @"iApp-a-Day Source Code" target: self action: @selector(showSource)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Drum" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showSpecialMenu)];
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
