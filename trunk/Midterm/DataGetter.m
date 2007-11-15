/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "DataGetter.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIProgressIndicator.h>

@implementation DataGetter

+(id)dataWithURL: (NSURL *)url
{
	return [[DataGetter alloc] initWithURL: url];
}

-(void)finishedTransferTarget: (id)target action: (SEL)action
{
	finishedTarget = [target retain];
	finishedAction = action;
}

-(void)done: (NSData*)data
{
	if( data && [data length] > 0 )
		[finishedTarget performSelector: finishedAction withObject: data afterDelay: 0];
	[self release];
}

-(void)getData: (NSURL*)url
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSData *data = [NSData dataWithContentsOfURL: url];
	[self performSelectorOnMainThread:@selector(done:) withObject:data waitUntilDone:NO];
	[pool release];
}

-(void)dealloc
{
	[finishedTarget release];
	[super dealloc];
}

-(id)initWithURL: (NSURL *)url
{
	[super init];
	[NSThread detachNewThreadSelector:@selector(getData:) toTarget:self withObject:url];
	return self;
}

@end
