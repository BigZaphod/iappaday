/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "CaptureView.h"
#import "MenuView.h"
#import "DataGetter.h"
#import "DataPoster.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

float r()
{
        return random() / (float)RAND_MAX;
}

@implementation SpaceView
extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseUp: ( struct __GSEvent *)e
{
	CGPoint p = GSEventGetLocationInWindow(e);
	CGPoint off = [[self superview] offset];
	p.x += off.x;
	p.y += off.y;
	[(App*)UIApp tappedAtPoint: p];
}
@end

@interface Note : UITextLabel {}
@end

@implementation Note
+(id)noteWithText: (NSString *)text andPoint: (CGPoint)point andRotation: (float)rotation
{
	Note *n = [[[Note alloc] init] autorelease];

	struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Marker Felt" traits:0 size:20+(10*r())];
	float alphaColor[] = { 0, 0, 0, 0 };
	float txtColor[] = { r(), r(), r(), 1 };

	[n setFont: font];
	[n setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[n setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)];
	[n setText: text];
	[n sizeToFit];
	[n setOrigin: point];
	[n setTransform: CGAffineTransformMakeRotation(rotation)];
	[n setAlpha: 0];

	return n;
}
@end

@interface Pic : UIImageView {}
@end

@implementation Pic
+(id)pictureWithData: (NSData *)data andPoint: (CGPoint)point andRotation: (float)rotation
{
	UIImage *img = [[[UIImage alloc] initWithData: data cache: NO] autorelease];
	Pic *p = [[[Pic alloc] initWithImage: img] autorelease];
	[p setOrigin: CGPointMake(point.x - [img size].width/2.0, point.y - [img size].height/2.0)];
	[p setTransform: CGAffineTransformMakeRotation(rotation)];
	[p setAlpha: 0];
	return p;
}
@end


@implementation App

-(void)removeItemsAsNeeded
{
	if( [items count] == 50 ) {
		id rm = [items lastObject];
		[rm setAlpha: 0];
		[rm performSelector: @selector(removeFromSuperview) withObject: nil afterDelay: 3.1];
		[items removeLastObject];
	}

}

-(void)addNote: (Note*)n
{
	[space addSubview: n];
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration:3];

	[n setAlpha: 0.8 + (r() * 0.2)];
	[items insertObject: n atIndex: 0];

	if( [items count] == 50 ) {
		id rm = [items lastObject];
		[rm setAlpha: 0];
		[rm performSelector: @selector(removeFromSuperview) withObject: nil afterDelay: 3.1];
		[items removeLastObject];
	}

	[UIView endAnimations];
}

-(void)addPicture: (Pic*)p
{
	[space addSubview: p];
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 1];
	[UIView setAnimationDuration:3];

	[p setAlpha: 0.8 + (r() * 0.2)];
	[items insertObject: p atIndex: 0];
	[self removeItemsAsNeeded];
	[UIView endAnimations];
}

-(void)gotItem: (NSData*)data
{
	id item = [NSPropertyListSerialization propertyListFromData: data mutabilityOption: NSPropertyListImmutable format:nil errorDescription: nil];
	if( item ) {
		if( [[item objectForKey: @"type"] compare: @"note"] == NSOrderedSame ) {
			[self addNote: [Note noteWithText: [item objectForKey: @"text"] andPoint: CGPointMake([[item objectForKey: @"x"] floatValue], [[item objectForKey: @"y"] floatValue]) andRotation: [[item objectForKey: @"rotation"] floatValue]]];
		} else if( [[item objectForKey: @"type"] compare: @"picture"] == NSOrderedSame ) {
			[self addPicture: [Pic pictureWithData: [item objectForKey: @"image"] andPoint: CGPointMake([[item objectForKey: @"x"] floatValue], [[item objectForKey: @"y"] floatValue]) andRotation: [[item objectForKey: @"rotation"] floatValue]]];
		}
	}
	[self performSelector: @selector(fetchItem) withObject: nil afterDelay: 1.6+r()];
}

-(void)fetchItem
{
	currentIndex = (currentIndex == 100)? 0: currentIndex+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://collage.iappaday.com/collage/%d.data",currentIndex]]];
	[get finishedTransferTarget: self action: @selector(gotItem:)];
	[get performRequest];
}

-(void)resumeTrackingRotation
{
	trackRotation = YES;
}

-(void)gotPictureData: (NSData*)pic
{
	NSDictionary *toSend = [NSDictionary dictionaryWithObjectsAndKeys:
		@"picture",					@"type",
		pic,						@"image",
		[NSNumber numberWithFloat: currentPoint.x],	@"x",
		[NSNumber numberWithFloat: currentPoint.y],	@"y",
		[NSNumber numberWithFloat: currentRotation],	@"rotation",
	nil];
	NSData *data = [NSPropertyListSerialization dataFromPropertyList: toSend format: NSPropertyListBinaryFormat_v1_0 errorDescription: nil];
	DataPoster *post = [DataPoster postToURL: [NSURL URLWithString: @"http://collage.iappaday.com/collage/new.php"]];
	[post sendData: data];
	[self addPicture: [Pic pictureWithData: pic andPoint: currentPoint andRotation: currentRotation]];

	[self resumeTrackingRotation];
}

-(void)showPictureEntry
{
	CaptureView *v = [[[CaptureView alloc] init] autorelease];
	[v gotPictureTarget: self action: @selector(gotPictureData:)];
	[v cancelPictureTarget: self action: @selector(resumeTrackingRotation)];
	[window addSubview: v];	
}

-(void)showNoteEntry
{
	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setDelegate: self];
	[alert addTextFieldWithValue: nil label: @"your message"];
	[alert addButtonWithTitle: @"Post"];
	[alert addButtonWithTitle: @"Cancel"];
	[alert popupAlertAnimated: YES];
	[alert setTag: 2];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( [sheet tag] == 1 ) {
		if( button == 1 ) {
			[self showNoteEntry];
		} else if( button == 2 ) {
			[self showPictureEntry];
		}
	} else if( [sheet tag] == 2 ) {
		if( button == 1 ) {
			NSString *str = [[sheet textFieldAtIndex:0] text];
			NSDictionary *toSend = [NSDictionary dictionaryWithObjectsAndKeys:
				@"note",					@"type",
				str,						@"text",
				[NSNumber numberWithFloat: currentPoint.x],	@"x",
				[NSNumber numberWithFloat: currentPoint.y],	@"y",
				[NSNumber numberWithFloat: currentRotation],	@"rotation",
			nil];
			NSData *data = [NSPropertyListSerialization dataFromPropertyList: toSend format: NSPropertyListBinaryFormat_v1_0 errorDescription: nil];
			DataPoster *post = [DataPoster postToURL: [NSURL URLWithString: @"http://collage.iappaday.com/collage/new.php"]];
			[post sendData: data];
			[self addNote: [Note noteWithText: str andPoint: currentPoint andRotation: currentRotation]];
		}
		[self resumeTrackingRotation];
	}

	[sheet dismissAnimated: YES];
}

-(void)tappedAtPoint: (CGPoint)p
{
	trackRotation = NO;
	currentPoint = p;

	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setDelegate: self];
	[alert setTitle: @"What do you want to do?"];
	[alert addButtonWithTitle: @"Write a note"];
	[alert addButtonWithTitle: @"Post a picture"];
	[alert addButtonWithTitle: @"Nothing"];
	[alert popupAlertAnimated: YES];
	[alert setTag: 1];
}

-(void)takeSnapshot
{
	[space ensureDrawnRect: [space frame]];
	CGImageRef img = [space createSnapshotWithRect: [space frame]];

	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	CGImageDestinationRef dest = CGImageDestinationCreateWithData( (CFMutableDataRef)output, CFSTR("public.jpeg"), 1, NULL );
	CGImageDestinationAddImage(dest, img, NULL);
	CGImageDestinationFinalize(dest);
	CGImageRelease( img );

	DataPoster *post = [DataPoster postToURL: [NSURL URLWithString: @"http://collage.iappaday.com/collage/snapshot.php"]];
	[post sendData: output];
}

-(void)resultOfNeedSnapshot: (NSData*)d
{
	if( d ) [self takeSnapshot];
	[self performSelector: @selector(needSnapshot) withObject: nil afterDelay: 70];
}

-(void)needSnapshot
{
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString:@"http://collage.iappaday.com/collage/needsnapshot"]];
	[get finishedTransferTarget: self action: @selector(resultOfNeedSnapshot:)];
	[get performRequest];
}

-(void)showSpace
{
	[self resumeTrackingRotation];
	UIScroller *s = [[[UIScroller alloc] initWithFrame: [window bounds]] autorelease];
	float bgColor[] = { 0, 0, 0, 1 };
	[s setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[s addSubview: space];
	[s setContentSize: [space bounds].size];
	[s setAllowsFourWayRubberBanding: YES];
	[window setContentView: s];
	[self performSelector: @selector(needSnapshot) withObject: nil afterDelay: 80];
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

-(void)showDigg
{
	// :-)
	[self openURL: [NSURL URLWithString: @"http://digg.com/apple/iApp_a_Day"]];
}

-(void)showOnTheWeb
{
	[self openURL: [NSURL URLWithString: @"http://collage.iappaday.com/collage/"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Collage" body: @"Participate at your own risk..."] autorelease];
	[menu addButtonWithTitle: @"Continue" target: self action: @selector(showSpace)];
	[menu addButtonWithTitle: @"View On The Web" target: self action: @selector(showOnTheWeb)];
	[menu addButtonWithTitle: @"Digg iApp-a-Day!" target: self action: @selector(showDigg)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Collage" andAuthor: @"Sean Heber <sean@spiffytech.com>" andArtist: nil] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

-(void)dealloc
{
	[space release];
	[items release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	window = [[UIWindow alloc] initWithContentRect: frame];
	float bgColor[] = { 0, 0, 0, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[window orderFront: self];
	[window makeKey: self];

	items = [[NSMutableArray alloc] init];
	currentIndex = r() * 100.0;

	space = [[SpaceView alloc] initWithFrame: CGRectMake(0,0,1000,1000)];
	[space setTilingEnabled: YES];
	[space setSizesTilesToFit: YES];
	[self fetchItem];

	[self showSplash];
}

@end

