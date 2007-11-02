/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UITextView.h>
#import <UIKit/UIButtonBarTextButton.h>

@implementation App

float r()
{
        return random() / (float)RAND_MAX;
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	NSString *urlStr = [NSString stringWithFormat:@"http://magic.iappaday.com/magic/wisdom.php?w=%s", [[[sheet textFieldAtIndex:0] text] cString]];
	NSURL *url = [NSURL URLWithString: [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	NSURLRequest* urlRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[NSURLConnection connectionWithRequest: urlRequest delegate: nil];	
	[sheet dismissAnimated: YES];
	[self showEightBall];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseDown: ( struct __GSEvent *)e
{
	if( !upsideDown || !playingBall ) return;

        CGPoint point = GSEventGetLocationInWindow(e);
	if( point.x >= 30 && point.x <= 200 && point.y >= 190 && point.y <= 300 ) {
		UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
		[alert setBodyText: @"Your suggested destiny will be shared with the world. Let wisdom guide your fingers."];
		[alert addTextFieldWithValue: nil label: @"destiny"];
		[alert addButtonWithTitle: @"Done"];
		[alert setDelegate: self];
		[alert popupAlertAnimated: YES];
		playingBall = NO;
	}
}

-(void)showBottomOfBall
{
	[label setText: [wisdoms objectAtIndex: (int)(r() * ([wisdoms count]-1))]];

	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];
	[v addSubview: [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"bottom.png"]] autorelease]];
	[v addSubview: triangle];
	[triangle setAlpha: 0];

	[UIView beginAnimations:nil];
	[UIView setAnimationDuration:2];
	[triangle setAlpha: 1];
	[UIView endAnimations];

	[window setContentView: v];

	upsideDown = YES;
}

-(void)showEightBall
{
	[triangle removeFromSuperview];
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];
	[v addSubview: [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease]];
	[window setContentView: v];
	playingBall = YES;
	upsideDown = NO;
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	if( !playingBall ) return;

	if( y >= 0.35 && !upsideDown ) {
		[self showBottomOfBall];
	} else if( upsideDown && y <= -0.40 ) {
		[self showEightBall];
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Magic" andAuthor: @"Sean Heber <sean@spiffytech.com>" andArtist: @"UnitOneNine <Lee@UnitOneNine.com>"] autorelease];
	[s continueTarget: self action: @selector(showEightBall)];
	[window setContentView: s];
}

-(void)dealloc
{
	[wisdoms release];
	[triangle release];
	[label release];
	[super dealloc];
}

-(void)fetchWisdom
{
	[NSThread detachNewThreadSelector:@selector(getWisdom) toTarget:self withObject:nil];
}

-(void)gotWisdom: (NSString *)str
{
	if( str ) {
		while( [wisdoms count] > 20 ) [wisdoms removeObjectAtIndex: (int)(r()*([wisdoms count]-1))];
		[wisdoms addObject: str];
	}
	[self performSelector: @selector(fetchWisdom) withObject: nil afterDelay: 2];
}

-(void)getWisdom
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int f = (int)(r()*100);
	id str = [NSString stringWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://magic.iappaday.com/magic/%d.txt", f]]];
	[self performSelectorOnMainThread:@selector(gotWisdom:) withObject:str waitUntilDone:NO];
	[pool release];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	frame.origin.y = 0;
	window = [[UIWindow alloc] initWithContentRect: frame];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	wisdoms = [[NSMutableArray alloc] init];
	[wisdoms addObject: @"Yes"];
	[wisdoms addObject: @"No"];
	[wisdoms addObject: @"Yes - definitely"];
	[wisdoms addObject: @"Outlook not so good"];
	[wisdoms addObject: @"Don't count on it"];

	triangle = [[UIView alloc] initWithFrame: CGRectMake(0,0,127,116)];
	[triangle addSubview: [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"triangle.png"]] autorelease]];
	float alphaColor[] = { 1, 1, 1, 0 };
	float txtColor[] = { 171/255.0f, 157/255.0f, 197/255.0f, 1 };
	label = [[UITextLabel alloc] initWithFrame: CGRectMake(-96.5,66,320,20)];
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[label setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)];
	[label setCentersHorizontally: YES];
	[triangle addSubview: label];

	id msg = [[UITextLabel alloc] initWithFrame: CGRectMake(-96.5,260,320,20)];
	[msg setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[msg setCentersHorizontally: YES];
	[msg setText: @"Tap the fortune to change destiny!"];
	[triangle addSubview: msg];


	[triangle setOrigin: CGPointMake(96.5,200)];
	[triangle setRotationBy: 180];

	[self fetchWisdom];

	[self showSplash];
}

@end
