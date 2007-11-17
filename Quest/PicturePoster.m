/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "PicturePoster.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIProgressIndicator.h>

@implementation PicturePoster

-(void)finishedTransferTarget: (id)target action: (SEL)action
{
	finishedTarget = target;
	finishedAction = action;
}

-(void)done
{
	[self removeFromSuperview];
	[finishedTarget performSelector: finishedAction withObject: nil afterDelay: 0];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(id)response
{
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// yay!
	[self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// ignore errors.. oh well  :)
	[connection cancel];
	[self done];
}

-(void)sendPictureData: (NSData *)data
{
	UIView *v = [[[UIView alloc] initWithFrame: [self bounds]] autorelease];
	[v setAlpha: 0.6];
	float bgColor[] = { 0, 0, 0, 1 };
	[v setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[self addSubview: v];


	float x = [self bounds].size.width - 30;
	float y = [self bounds].size.height - 30;
	UIProgressIndicator *p = [[[UIProgressIndicator alloc] initWithFrame: CGRectMake(x,y,[UIProgressIndicator size].width, [UIProgressIndicator size].height)] autorelease];
	[p startAnimation];
	[self addSubview: p];

	float alphaColor[] = { 0, 0, 0, 0 };
	float whiteColor[] = { 1, 1, 1, 1 };
	UITextLabel *txt = [[[UITextLabel alloc] initWithFrame: CGRectMake(18, y,[self bounds].size.width,20)] autorelease];
	[txt setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[txt setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), whiteColor)];
	[txt setText: @"hang on a sec - telling the world..."];
	[self addSubview: txt];

	NSMutableURLRequest* urlRequest = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
	[urlRequest setHTTPMethod: @"POST"];
	[urlRequest setHTTPBody: data];
	[NSURLConnection connectionWithRequest: urlRequest delegate: self];
}

-(void)dealloc
{
	[url release];
	[super dealloc];
}

-(id)initWithURL: (NSURL *)sendurl inView: (UIView *)view
{
	[super initWithFrame: [view bounds]];
	url = [sendurl retain];
	[view addSubview: self];
	[view bringSubviewToFront: self];
	return self;
}

@end
