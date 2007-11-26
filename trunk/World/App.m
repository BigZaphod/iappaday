/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "CaptureView.h"
#import "DataPoster.h"
#import "DataGetter.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

@implementation App

-(void)stopDisplayingPhotos
{
	hidingPhotos = YES;
	[currentPhoto setOrigin: CGPointMake(-220,130)];   // sorta silly...
}

-(void)resumeDisplayingPhotos
{
	hidingPhotos = NO;
	[currentPhoto setOrigin: CGPointMake(50,130)];
}

-(void)gotPictureData: (NSData*)pic
{
	NSDictionary *toSend = [NSDictionary dictionaryWithObjectsAndKeys:
		pic,					@"image",
		[NSNumber numberWithFloat: tapped.x],	@"x",
		[NSNumber numberWithFloat: tapped.y],	@"y",
        nil];
	NSData *data = [NSPropertyListSerialization dataFromPropertyList: toSend format: NSPropertyListBinaryFormat_v1_0 errorDescription: nil];
	DataPoster *post = [DataPoster postToURL: [NSURL URLWithString: @"http://world.iappaday.com/world/here.php"]];
	[post sendData: data];
	[self resumeDisplayingPhotos];
}

-(void)capturePicture
{
	CaptureView *v = [[[CaptureView alloc] init] autorelease];
	[v gotPictureTarget: self action: @selector(gotPictureData:)];
	[v cancelPictureTarget: self action: @selector(resumeDisplayingPhotos)];
	[window addSubview: v];
}

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
-(void)mouseUp:(struct __GSEvent *)e
{
	if( !hidingPhotos ) {
		CGPoint p = GSEventGetLocationInWindow(e);
		p.x -= [target bounds].size.width/2.0;
		p.y -= [target bounds].size.height/2.0;
		tapped = p;
		[target setOrigin: p];
		[self stopDisplayingPhotos];
		[self performSelector: @selector(capturePicture) withObject: nil afterDelay: 0.3];
	}
}

-(void)fetchWorldPhotos
{
	currentIndex = (currentIndex == 100)? 0: currentIndex+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://world.iappaday.com/world/%d.data",currentIndex]]];
	[get finishedTransferTarget: self action: @selector(gotWorldPhoto:)];
	[get performRequest];
}

-(void)fadeOutPhoto
{
	[UIView beginAnimations:nil];
	[UIView setAnimationDuration:1];
	[currentPhoto setAlpha: 0];
	[UIView endAnimations];
}

-(void)playPhoto: (NSData*)jpg at: (CGPoint)p
{
	[currentPhoto setImage: [[[UIImage alloc] initWithData: jpg cache: NO] autorelease]];
	[currentPhoto setAlpha: 0];
	[UIView beginAnimations:nil];
	[UIView setAnimationDuration:1];
	[target setOrigin: p];
	[currentPhoto setAlpha: 0.84];
	[UIView endAnimations];
	[self performSelector: @selector(fadeOutPhoto) withObject: nil afterDelay: 4.1];
}

-(void)gotWorldPhoto: (NSData*)data
{
	id item = [NSPropertyListSerialization propertyListFromData: data mutabilityOption: NSPropertyListImmutable format:nil errorDescription: nil];
	if( item ) {
		[self playPhoto: [item objectForKey: @"image"] at: CGPointMake([[item objectForKey: @"x"] floatValue], [[item objectForKey: @"y"] floatValue])];
	}
	[self performSelector: @selector(fetchWorldPhotos) withObject: nil afterDelay: 5.4];
}

-(void)showTheWorld
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"world.jpg"]] autorelease];

	target = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"target.png"]];
	[target setOrigin: CGPointMake(-100,-100)];
	[bg addSubview: target];

	currentPhoto = [[UIImageView alloc] init];
	[currentPhoto setRotationBy: 90];
	[bg addSubview: currentPhoto];

	[self resumeDisplayingPhotos];
	[self fetchWorldPhotos];

	[window setContentView: bg];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"World" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: nil] autorelease];
	[s continueTarget: self action: @selector(showTheWorld)];
	[window setContentView: s];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: YES];
}

-(void)dealloc
{
	[target release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	currentIndex = 0;
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
