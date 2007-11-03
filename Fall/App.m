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

-(void)snow
{
	static flakes = 400;

	UIImageView *flake = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"snowflake.png"]] autorelease];
	[flake setOrigin: CGPointMake((330*r())-10, -20)];
	[window addSubview: flake];

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration:0.8];
	[flake setOrigin: CGPointMake([flake origin].x, 337 + (r()*110))];
	[UIView endAnimations];

	flakes--;
	if( flakes )
		[self performSelector:@selector(snow) withObject:nil afterDelay:0.27];
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	static BOOL canFall = NO;

	if( fabs(y) < 0.28 && !canFall ) 
		canFall = YES;

	if( fabs(y) > 0.3 && canFall && [leaves count] > 0 ) {
		int index = r() * [leaves count];
		id z = [leaves objectAtIndex: index];
		[leaves removeObjectAtIndex: index];

		[UIView beginAnimations:nil];
		[UIView setAnimationCurve: 1];
		[UIView setAnimationDuration:0.65];
		[z setOrigin: CGPointMake([z origin].x, 370 + (r()*50))];
		[UIView endAnimations];

		if( [leaves count] == 0 )
			[self snow];

		canFall = NO;
	}
}

-(void)showTree
{
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];
	[v addSubview: [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease]];

	UIImage *colors[4] = {
		[UIImage applicationImageNamed: @"red.png"],
		[UIImage applicationImageNamed: @"yellow.png"],
		[UIImage applicationImageNamed: @"brown.png"],
		[UIImage applicationImageNamed: @"green.png"]
	};

	int i;
	for( i=0; i<numPoints; i++ ) {
		UIImageView *l = [[[UIImageView alloc] initWithImage: colors[(int)(r()*4)]] autorelease];
		[l setOrigin: points[i]];
		[l setRotationBy: (100*r())-50];
		[v addSubview: l];
		[leaves addObject: l];
	}

	[window setContentView: v];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Fall" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showTree)];
	[window setContentView: s];
}

-(void)dealloc
{
	[leaves release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	points[0] = CGPointMake(134,212);
	points[1] = CGPointMake(168,221);
	points[2] = CGPointMake(167,180);
	points[3] = CGPointMake(204,184);
	points[4] = CGPointMake(243,154);
	points[5] = CGPointMake(233,175);
	points[6] = CGPointMake(215,154);
	points[7] = CGPointMake(234,131);
	points[8] = CGPointMake(232,113);
	points[9] = CGPointMake(275,125);
	points[10] = CGPointMake(226,193);
	points[11] = CGPointMake(113,201);
	points[12] = CGPointMake(77,206);
	points[13] = CGPointMake(97,175);
	points[14] = CGPointMake(87,146);
	points[15] = CGPointMake(50,180);
	points[16] = CGPointMake(59,136);
	points[17] = CGPointMake(62,167);
	points[18] = CGPointMake(136,178);
	points[19] = CGPointMake(145,159);
	points[20] = CGPointMake(119,137);
	points[21] = CGPointMake(164,135);
	points[22] = CGPointMake(187,118);
	points[23] = CGPointMake(165,100);
	points[24] = CGPointMake(112,108);
	points[25] = CGPointMake(70,113);
	points[26] = CGPointMake(203,196);
	leaves = [[NSMutableArray alloc] init];

	[self showSplash];
}

@end
