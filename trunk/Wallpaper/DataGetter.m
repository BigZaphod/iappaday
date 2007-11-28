/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "DataGetter.h"

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
	[requestURL release];
	[finishedTarget release];
	[super dealloc];
}

-(void)performRequest
{
	[NSThread detachNewThreadSelector:@selector(getData:) toTarget:self withObject:requestURL];
}

-(id)initWithURL: (NSURL *)url
{
	[super init];
	requestURL = [url retain];
	return self;
}

@end
