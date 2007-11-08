/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "Splash.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController.h>

float angle = 0;
BOOL bounce;

@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	if( fabsf(x) > 0.15 ) {
		angle = x;
		bounce = NO;
	} else {
		bounce = YES;
	}
}

-(void)closeMouth
{
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 3];
	[UIView setAnimationDuration: 0.2];
	[chin setOrigin: CGPointMake(64,243)];
	[UIView endAnimations];
	[self performSelector:@selector(boom) withObject:self afterDelay:0];
}

-(void)sayBoom
{
	float r = random() / (float)RAND_MAX;
	int snd = (int)(r * 11);

	AVController *c = [[AVController alloc] init];
        AVItem *s = [AVItem avItemWithPath:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"boom%d",snd] ofType:@"wav" inDirectory:@"/"] error: nil];
	double howlong = [s duration];
        [c setCurrentItem: s preservingRate:YES];
        [c play: nil];	

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration: howlong];
	[chin setOrigin: CGPointMake(64,265)];
	[UIView endAnimations];

	[self performSelector:@selector(closeMouth) withObject:self afterDelay:howlong+0.5];
}

-(void)boom
{
	float r = random() / (float)RAND_MAX;
	r = 1.5 + (r * 7.5);
	[self performSelector:@selector(sayBoom) withObject:self afterDelay:r];
}

- (void)bob
{
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 0];
	[UIView setAnimationDuration:0.3];

	CGAffineTransform transform;
	transform = CGAffineTransformMakeTranslation( 0, 135);
	transform = CGAffineTransformRotate(transform,angle);
	transform = CGAffineTransformTranslate( transform, 0, -135);
	[head setTransform: transform];

	[UIView endAnimations];

	if( bounce )
		angle = (angle * -1) * 0.82;

	[self performSelector:@selector(bob) withObject:self afterDelay:0.34];
}

-(void)startApp
{
	UIView *v = [[UIView alloc] initWithFrame: [window bounds]];

	UIImageView *body = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"body.png"]];
	[body setOrigin: CGPointMake(0,287)];
	[v addSubview: body];

	head = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"head.png"]];
	[head setOrigin: CGPointMake(46,50)];
	[v addSubview: head];

	chin = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"chin.png"]];
	[chin setOrigin: CGPointMake(64,243)];
	[head addSubview: chin];

	[window setContentView: v];

	[self bob];
	[self boom];
}

-(void)showSplash
{
	Splash *s = [[Splash alloc] initWithName: @"Uncle" andAuthor:@"Sean Heber <sean@spiffytech.com>"];
	[s continueTarget: self action: @selector(startApp)];
	[window setContentView: s];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
