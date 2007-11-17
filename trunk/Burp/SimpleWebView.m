/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "SimpleWebView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Rendering.h>

@implementation SimpleWebView

-(void)menuTarget: (id)target action: (SEL)action
{
	menuTarget = target;
	menuAction = action;
}

-(void)view: (id)v didSetFrame:(CGRect)f
{
	if( v == webView )
		[scroller setContentSize: CGSizeMake(f.size.width, f.size.height)];
}

-(void)view:(id)v didDrawInRect:(CGRect)f duration:(float)d
{
	if( v == webView )
		[scroller setContentSize: [webView bounds].size];
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

-(id)initWithFrame: (CGRect)frame andURL: (NSURL *)url
{
	[super initWithFrame: frame];

	float h = [UINavigationBar  defaultSize].height;
	frame.size.height -= h;

	scroller = [[UIScroller alloc] initWithFrame: frame];
	[scroller setScrollingEnabled: YES];
	[scroller setAdjustForContentSizeChange: YES];
	[scroller setClipsSubviews: YES];
	[scroller setAllowsRubberBanding: YES];
	[scroller setDelegate: self];
	[self addSubview: scroller];

	webView = [[UIWebView alloc] initWithFrame: [scroller bounds]];
	[webView setTilingEnabled: YES];
	[webView setTileSize: CGSizeMake(frame.size.width,1000)];
	[webView setAutoresizes: YES];
	[webView setDelegate: self];
	[scroller addSubview: webView];

        urlRequest = [[NSURLRequest requestWithURL: url] retain];
	[webView loadRequest: urlRequest];

	UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, frame.size.height, [UINavigationBar  defaultSize].width, h)] autorelease];
	[bar showButtonsWithLeftTitle:@"Menu"  rightTitle:@"Refresh" leftBack: NO];
	[bar setBarStyle: 1];
	[bar setDelegate: self];
	[self addSubview: bar];

	return self;
}

@end
