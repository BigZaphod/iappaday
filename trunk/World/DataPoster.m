/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "DataPoster.h"

@implementation DataPoster

+(id)postToURL: (NSURL *)url
{
	return [[DataPoster alloc] initWithURL: url];
}

-(void)finishedTransferTarget: (id)target action: (SEL)action
{
	finishedTarget = [target retain];
	finishedAction = action;
}

-(void)done
{
	[finishedTarget performSelector: finishedAction withObject: nil afterDelay: 0];
	[self release];
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

-(void)sendData: (NSData *)data
{
	NSMutableURLRequest* urlRequest = [[[NSMutableURLRequest alloc] initWithURL:requestURL] autorelease];
	[urlRequest setHTTPMethod: @"POST"];
	[urlRequest setHTTPBody: data];
	[NSURLConnection connectionWithRequest: urlRequest delegate: self];
}

-(void)dealloc
{
	[requestURL release];
	[super dealloc];
}

-(id)initWithURL: (NSURL *)url
{
	[super init];
	requestURL = [url retain];
	return self;
}

@end
