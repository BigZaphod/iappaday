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

float r()
{
        return random() / (float)RAND_MAX;
}

-(void)doVibrate
{
	vibrate( 5 );
}

-(void)vibrate
{
	[NSThread detachNewThreadSelector:@selector(doVibrate) toTarget:self withObject:nil];
}

-(void)showButton
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	UIImageView *button = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"button.png"]] autorelease];
	[button setOrigin: CGPointMake( ([bg bounds].size.width/2.0) - ([button bounds].size.width / 2.0), ([bg bounds].size.height/2.0) - ([button bounds].size.height / 2.0))];
	[bg addSubview: button];
	[window setContentView: bg];
	waiting = YES;
}

-(void)doneWithPanic
{
	waiting = YES;
	[self showButton];
}

-(void)PANIC
{
	UIImage *img = [UIImage applicationImageNamed: (panics > 3 && r() > 0.6)? @"chicken.jpg": @"panic.jpg"];
	UIImageView *me = [[[UIImageView alloc] initWithImage: img] autorelease];
	[window setContentView: me];
	[c setCurrentItem: scream];
	[c play: nil];
	[self vibrate];
	[self performSelector: @selector(doneWithPanic) withObject: nil afterDelay: 5.8];
	panics++;
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseUp:( struct __GSEvent *)e
{
	CGPoint p = GSEventGetLocationInWindow(e);
	if( waiting ) {
		waiting = NO;
		[self performSelector: @selector(PANIC) withObject: nil afterDelay: 0.2 + (1*r())];
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"I think I'm going insane!" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showButton)];
	[window setContentView: s];
}

-(void)dealloc
{
	[scream release];
	[c release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	panics = 0;
	c = [[AVController avController] retain];
	scream = [[AVItem avItemWithPath:[[NSBundle mainBundle] pathForResource:@"scream" ofType:@"mov" inDirectory:@"/"] error: nil] retain];

	[self showSplash];
}

@end
