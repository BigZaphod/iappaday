/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "SimpleWebView.h"
#import <UIKit/UIView-Geometry.h>

@implementation SimpleWebView

-(void)menuTarget: (id)target action: (SEL)action
{
	menuTarget = target;
	menuAction = action;
}

-(void)view: (UIView*)v didSetFrame:(CGRect)f
{
	if( v == webView ) {
		[scroller setContentSize: CGSizeMake(f.size.width, f.size.height)];
		[v setNeedsDisplay];
	}
}

/*
-(BOOL)respondsToSelector:(SEL)sel
{
	NSLog(@"respondsToSelector \"%@\"\n",	NSStringFromSelector(sel));
	return [super respondsToSelector: sel];
}
*/

-(void)dealloc
{
	[urlRequest release];
	[webView release];
	[scroller release];
	[super dealloc];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 1 ) {
		[menuTarget performSelector: menuAction withObject: nil afterDelay: 0];
	} else {
		[webView loadRequest: urlRequest];		
	}
}

-(id)initWithFrame: (CGRect)frame andURL: (NSURL *)url andReloadURL: (NSURL *)reload
{
	[super initWithFrame: frame];

	float h = [UINavigationBar  defaultSize].height;
	frame.size.height -= h;

	scroller = [[UIScroller alloc] initWithFrame: frame];
	[scroller setScrollingEnabled: YES];
	[scroller setAdjustForContentSizeChange: NO];
	[scroller setClipsSubviews: YES];
	[scroller setAllowsFourWayRubberBanding: YES];
	[self addSubview: scroller];

	webView = [[UIWebView alloc] initWithFrame: [scroller bounds]];
	[webView setAutoresizes: YES];
	[webView setDelegate: self];
	[scroller addSubview: webView];

	[webView loadRequest: [NSURLRequest requestWithURL: url]];
        urlRequest = [[NSURLRequest requestWithURL: reload] retain];

	UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, frame.size.height, [UINavigationBar  defaultSize].width, h)] autorelease];
	[bar showButtonsWithLeftTitle:@"Try Again"  rightTitle:@"Refresh" leftBack: NO];
	[bar setBarStyle: 1];
	[bar setDelegate: self];
	[self addSubview: bar];

	return self;
}

@end
