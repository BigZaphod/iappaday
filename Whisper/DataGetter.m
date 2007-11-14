/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "DataGetter.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIProgressIndicator.h>

@implementation DataGetter

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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[output writeData: data];
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

-(void)getData
{
	UIView *v = [[[UIView alloc] initWithFrame: [self bounds]] autorelease];
	[v setAlpha: 0.6];
	float bgColor[] = { 0, 0, 0, 1 };
	[v setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[self addSubview: v];

	float x = [self bounds].size.width - 30;
	float y = 15;
	UIProgressIndicator *p = [[[UIProgressIndicator alloc] initWithFrame: CGRectMake(x,y,[UIProgressIndicator size].width, [UIProgressIndicator size].height)] autorelease];
	[p startAnimation];
	[self addSubview: p];

	float alphaColor[] = { 0, 0, 0, 0 };
	float whiteColor[] = { 1, 1, 1, 1 };
	UITextLabel *txt = [[[UITextLabel alloc] initWithFrame: CGRectMake(18, y,[self bounds].size.width,20)] autorelease];
	[txt setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[txt setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), whiteColor)];
	[txt setText: @"listening for a secret..."];
	[self addSubview: txt];

	NSURLRequest* urlRequest = [[[NSURLRequest alloc] initWithURL:url] autorelease];
	[NSURLConnection connectionWithRequest: urlRequest delegate: self];
}

-(void)dealloc
{
	[output release];
	[url release];
	[super dealloc];
}

-(id)initWithURL: (NSURL *)sendurl inView: (UIView *)view toFileAtPath: (NSString *)path
{
	[super initWithFrame: [view bounds]];

	url = [sendurl retain];

	[[NSFileManager defaultManager] createFileAtPath: path contents: nil attributes: nil];
	output = [[NSFileHandle fileHandleForWritingAtPath: path] retain];
	[output truncateFileAtOffset: 0];

	[view addSubview: self];
	[view bringSubviewToFront: self];
	[self getData];
	return self;
}

@end
