/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

static UIImage *petal;

float r()
{
	return random() / (float)RAND_MAX;
}


@interface Petal : UIImageView {
}
-(id)initAtCenter: (CGPoint)p;
-(void)run;
@end

@implementation Petal

-(id)initAtCenter: (CGPoint)p
{
	[super initWithImage: petal];
	CGSize sz = [self bounds].size;
	[self setOrigin: CGPointMake(p.x - (sz.width/2.0f), p.y - (sz.height/2.0f))];
	[self setTransform: CGAffineTransformMakeRotation(r()*2*M_PI)];
	[self run];
	return self;
}

-(void)run
{
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: (int)(r()*3)];
	[UIView setAnimationDuration:5];
	[self setTransform: CGAffineTransformScale(CGAffineTransformRotate([self transform],r()),80,80)];
	[UIView endAnimations];
	[self performSelector:@selector(removeFromSuperview) withObject:self afterDelay:6];
}

@end


@implementation App

-(void)runFlower
{
	CGPoint center = CGPointMake( [window bounds].size.width/2.f, [window bounds].size.height/2.f );
	id s = [[[Petal alloc] initAtCenter: center] autorelease];
	[window addSubview: s];
	[self performSelector:@selector(runFlower) withObject:self afterDelay:0.37];
}

-(void)showFlower
{
	float bgColor[] = { 1, 1, 1, 1 };
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];
	[v setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[window setContentView: v];
	[self runFlower];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Rose" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showFlower)];
	[window setContentView: s];
}

-(void)dealloc
{
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];

	[window orderFront: self];
	[window makeKey: self];

	petal = [UIImage applicationImageNamed:@"petal.png"];

	[self showSplash];
}

@end
