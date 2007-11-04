/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "SimpleWebView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

static float meltSteps = 1200;

@implementation App

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: YES];
	SimpleWebView *w = [[[SimpleWebView alloc] initWithFrame: [window bounds] andURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://melt.iappaday.com/melt/report.php?s=%f",seconds]] andReloadURL: [NSURL URLWithString: @"http://melt.iappaday.com/melt/"] ] autorelease];
	[w menuTarget: self action: @selector(showIce)];
	[window setContentView: w];
}

-(void)counterLoop
{
	if( progress >= meltSteps ) {
		UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
		[alert setDelegate: self];
		[alert setBodyText: [NSString stringWithFormat:@"Congratulations!\nYou melted the ice cubes in %0.1f seconds!", seconds]];
		[alert setDimsBackground: NO];
		[alert addButtonWithTitle: @"View Global Stats"];
		[alert popupAlertAnimated: YES];
	} else {
		seconds += 0.1;
		[label setText: [NSString stringWithFormat:@"Time: %0.1f",seconds]];
		[self performSelector:@selector(counterLoop) withObject:self afterDelay:0.1];
	}
}

-(void)showIce
{
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];
	[v addSubview: [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"title.png"]] autorelease]];

	[v addSubview: label];


	[ice setOrigin: CGPointMake(89,-140)];
	[ice setTransform: CGAffineTransformMakeScale(1,1)];
	[v addSubview: ice];

	[shadow setOrigin: CGPointMake(72,265)];
	[v addSubview: shadow];

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration:0.65];

	[ice setOrigin: CGPointMake(89,150)];

	[UIView endAnimations];

	progress = 0;
	seconds = 0;
	[self counterLoop];

	[window setContentView: v];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseDragged:( struct __GSEvent *)e
{
	CGPoint p = GSEventGetLocationInWindow(e);
	if( p.x >= 115 && p.x <= 230 && p.y >= 160 && p.y <= 280 ) {
		progress++;
		if( progress < meltSteps ) {
			float m = progress/meltSteps;
			[ice setOrigin: CGPointMake(89+(65*m), 150+(130*m)  )];
			[ice setTransform: CGAffineTransformMakeScale( 1.0-m, 1.0-m )];
		}
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Melt" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showIce)];
	[window setContentView: s];
}

-(void)dealloc
{
	[label release];
	[ice release];
	[shadow release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	ice = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"ice.png"]];
	shadow = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"shadow.png"]];
	label = [[UITextLabel alloc] initWithFrame: CGRectMake(0,400,[window bounds].size.width,50)];
	[label setCentersHorizontally: YES];

	[self showSplash];
}

@end
