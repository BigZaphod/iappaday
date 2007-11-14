/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

@implementation App

float r()
{
	return random() / (float)RAND_MAX;
}

-(void)showBush
{
	poked = false;
	UIImageView *bush = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	[window setContentView: bush];
}

-(void)mouseDown: ( struct __GSEvent *)e
{
	if( poked ) return;
	poked = true;

	int face = [faces count] * r();
	int sound = [sounds count] * r();
	[window setContentView: [[[UIImageView alloc] initWithImage: [faces objectAtIndex:face]] autorelease]];

	[av setCurrentItem: [sounds objectAtIndex:sound]];
	[av play: nil];

	[self performSelector:@selector(showBush) withObject:self afterDelay:1.85];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Poke" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showBush)];
	[window setContentView: s];
}

-(void)dealloc
{
	[faces release];
	[sounds release];
	[av release];
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

	av = [[AVController avController] retain];
	sounds = [[NSMutableArray alloc] init];
	faces = [[NSMutableArray alloc] init];

	int i;
	for( i=0; i<=14; i++ ){
		NSString *path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%d",i] ofType:@"mp3" inDirectory:@"/"];
		AVItem *s = [AVItem avItemWithPath: path error: nil];
		[sounds addObject: s];
	}

	for( i=0; i<=3; i++ ){
		[faces addObject: [UIImage applicationImageNamed:[NSString stringWithFormat:@"%d.jpg",i]]];
	}

	[self showSplash];
}

@end
