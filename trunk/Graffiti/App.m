/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

float r()
{
        return random() / (float)RAND_MAX;
}


@interface Graffiti : UITextLabel {}
@end

@implementation Graffiti
+(id)graffitiWithText: (NSString *)text andPoint: (CGPoint)point andRotation: (float)rotation
{
	Graffiti *g = [[[Graffiti alloc] init] autorelease];

	struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Marker Felt" traits:(int)(r()*3.0) size:30+(r()*28.0)];
	float alphaColor[] = { 0, 0, 0, 0 };
	float txtColor[] = { r(), r(), r(), 1 };

	[g setFont: font];
	[g setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[g setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)];
	[g setText: text];
	[g sizeToFit];
	[g setOrigin: point];
	[g setTransform: CGAffineTransformMakeRotation(rotation)];
	[g setAlpha: 0];

	return g;
}
@end


@implementation MyImageView
-(void)dealloc
{
	[target release];
	[super dealloc];
}

-(void)messageEnterDelegate: (id)t
{
	target = [t retain];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseUp: ( struct __GSEvent *)e
{
	CGPoint p = GSEventGetLocationInWindow(e);
	id s = [self superview];
	CGPoint off = [s offset];
	p.x += off.x;
	p.y += off.y;
	[target enterMessageAtPoint: p];
}
@end


@implementation App

-(void)removeGraffitiFromSuperview: (Graffiti*)g
{
	[g removeFromSuperview];
}

-(void)addGraffiti: (Graffiti*)g
{
	[wall addSubview: g];
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration:3];

	[g setAlpha: 0.7 + (r() * 0.28)];
	[graffiti insertObject: g atIndex: 0];

	if( [graffiti count] == 35 ) {
		id rm = [graffiti lastObject];
		[rm setAlpha: 0];
		[self performSelector: @selector(removeGraffitiFromSuperview:) withObject: rm afterDelay: 3.1];
		[graffiti removeLastObject];
	}

	[UIView endAnimations];
}

-(void)gotGraffitiText: (NSString*)txt
{
	id parts = [txt componentsSeparatedByString: @"\n"];
	if( parts && [parts count] == 4 )
		[self addGraffiti: [Graffiti graffitiWithText: [parts objectAtIndex:3] andPoint: CGPointMake([[parts objectAtIndex:0] floatValue], [[parts objectAtIndex:1] floatValue]) andRotation: [[parts objectAtIndex:2] floatValue]]];
}

-(void)fetchGraffiti
{
	[self performSelector: @selector(fetchGraffitiNow) withObject: nil afterDelay: 1.6+r()];
}

-(void)fetchGraffitiNow
{
	currentIndex = (currentIndex == 100)? 0: currentIndex+1;
	[NSThread detachNewThreadSelector:@selector(getGraffiti:) toTarget:self withObject:[NSNumber numberWithInt: currentIndex]];
}

-(void)getGraffiti: (NSNumber*)atIndex
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	id str = [NSString stringWithContentsOfURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://graffiti.iappaday.com/graffiti/%d.txt", [atIndex intValue]]]];	
	if( str && [str length] > 0 )
		[self performSelectorOnMainThread:@selector(gotGraffitiText:) withObject:str waitUntilDone:NO];
	[self performSelectorOnMainThread:@selector(fetchGraffiti) withObject:nil waitUntilDone:NO];
	[pool release];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 ) {
		NSString *str = [[sheet textFieldAtIndex:0] text];
		NSString *urlStr = [NSString stringWithFormat:@"http://graffiti.iappaday.com/graffiti/add.php?t=%s&x=%f&y=%f&r=%f", [[str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding] cString], currentPoint.x, currentPoint.y, currentRotation];
		NSURL *url = [NSURL URLWithString: urlStr];
		NSURLRequest* urlRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
		[NSURLConnection connectionWithRequest: urlRequest delegate: nil];
		[self addGraffiti: [Graffiti graffitiWithText: str andPoint: currentPoint andRotation: currentRotation]];
	}
	[sheet dismissAnimated: YES];
	trackRotation = YES;
}

-(void)enterMessageAtPoint: (CGPoint)p
{
	trackRotation = NO;
	currentPoint = p;
	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setDelegate: self];
	[alert addTextFieldWithValue: nil label: @"your message"];
	[alert addButtonWithTitle: @"Say it"];
	[alert addButtonWithTitle: @"Don't spray it"];
	[alert popupAlertAnimated: YES];
}

-(void)showWall
{
	trackRotation = YES;
	UIScroller *s = [[[UIScroller alloc] initWithFrame: [window bounds]] autorelease];
	wall = [[MyImageView alloc] initWithImage: [UIImage applicationImageNamed:@"wall.jpg"]];
	[wall messageEnterDelegate: self];
	[s addSubview: wall];
	[s setContentSize: [wall bounds].size];
	[s setAllowsFourWayRubberBanding: NO];
	[s setOffset: CGPointMake([wall bounds].size.width/2.0,0)];
	[s setTapDelegate: self];
	[window setContentView: s];
	[self fetchGraffitiNow];
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	if( trackRotation ) {
		// I somehow suspect this method is mathematically stupid.. but I don't have the time to figure it out :)
		if( y <= 0 ) {
			currentRotation = M_PI*x;
		} else {
			currentRotation = M_PI-(M_PI*x);
		}
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Graffiti" andAuthor: @"Sean Heber <sean@spiffytech.com>" andArtist: nil] autorelease];
	[s continueTarget: self action: @selector(showWall)];
	[window setContentView: s];
}

-(void)dealloc
{
	[graffiti release];
	[wall release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	window = [[UIWindow alloc] initWithContentRect: frame];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[window orderFront: self];
	[window makeKey: self];

	graffiti = [[NSMutableArray alloc] init];
	currentIndex = r() * 100.0;

	[self fetchGraffitiNow];
	[self showSplash];
}

@end
