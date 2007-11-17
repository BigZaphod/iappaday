/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import "vib.h"

@implementation App

-(void)doVibrate
{
	vibrate( 1 );
	[UIApp performSelectorOnMainThread: @selector(doneVibrating) withObject: nil waitUntilDone: NO];
}

-(void)donePlaying
{
	playing = NO;
}

-(void)doneVibrating
{
	vibrating = NO;
}

-(void)vibrate
{
	vibrating = YES;
	[NSThread detachNewThreadSelector:@selector(doVibrate) toTarget:self withObject:nil];
}

-(void)showElmo
{
	[window setContentView:[[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease] ];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseDragged:( struct __GSEvent *)e
{
	CGPoint p = GSEventGetLocationInWindow(e);
	if( !vibrating ) [self vibrate];
	if( !playing ) {
		[c setCurrentItem: laugh];
		[c play: nil];	
		playing = YES;
		[self performSelector: @selector(donePlaying) withObject: nil afterDelay: 3];   // VERY hacky.. oh well :)
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Elmo" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showElmo)];
	[window setContentView: s];
}

-(void)dealloc
{
	[c release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];



	c = [[AVController avController] retain];
	laugh = [[AVItem avItemWithPath:[[NSBundle mainBundle] pathForResource:@"laugh" ofType:@"mp4" inDirectory:@"/"] error: nil] retain];

	[self showSplash];
}

@end
