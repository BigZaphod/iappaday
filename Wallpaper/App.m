/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "DataPoster.h"
#import "DataGetter.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UITransitionView.h>

float r()
{
	return random() / (float)RAND_MAX;
}

static NSMutableData* imageToData( UIImage* img ) {
	NSMutableData *data = [[[NSMutableData alloc] init] autorelease];
	CGImageDestinationRef dest = CGImageDestinationCreateWithData( (CFMutableDataRef)data, CFSTR("public.jpeg"), 1, NULL );
	CGImageDestinationAddImage(dest, [img imageRef], NULL);
	CGImageDestinationFinalize(dest);
	return data;
}

@interface PreviewWindow : UIImageView {
	id closeTarget;
	SEL closeAction;
}
@end

@implementation PreviewWindow
-(void)showMenu
{
	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setTitle: @"What's yours is mine..."];
	[alert addButtonWithTitle: @"Use As Wallpaper"];
	[alert addButtonWithTitle: @"Add To Camera Roll"];
	[alert addButtonWithTitle: @"Nevermind"];
	[alert setAlertSheetStyle: 1];
	[alert setDelegate: self];
	[alert presentSheetInView: self];
}

-(void)saveToCameraRoll: (NSData*)jpegdata
{
	// I am quite sure there should be a more "proper" way to do this... but this method works :)
	// logic "borrowed" from: http://svn.natetrue.com/dock/SpecialButtons.m

	NSString *pfolder = @"/private/var/root/Media/DCIM/100APPLE/";
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *pathname;
	int fnum;

	// trying to make the proper place on the touch...
	[fm createDirectoryAtPath: @"/private/var/root/Media" attributes: nil];
	[fm createDirectoryAtPath: @"/private/var/root/Media/DCIM" attributes: nil];
	[fm createDirectoryAtPath: @"/private/var/root/Media/DCIM/100APPLE" attributes: nil];

	for( fnum=9000; fnum<=9999; fnum++ ) {
		pathname = [NSString stringWithFormat:@"%@IMG_%4d.JPG", pfolder, fnum];
		if( ![fm fileExistsAtPath:pathname] ) break;
	}

	if( fnum == 9999 ) {
		// couldn't find a slot... bummer.
		return;
	}

	NSString *paththumb = [NSString stringWithFormat:@"%@IMG_%4d.THM", pfolder, fnum];

	[jpegdata writeToFile: pathname atomically: NO];
	[jpegdata writeToFile: paththumb atomically: NO];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 ) {
		[UIImage setDesktopImageData: imageToData([self image])];
	} else if( button == 2 ) {
		[self saveToCameraRoll: imageToData([self image])];
	}
	[sheet dismissAnimated: YES];
	[self removeFromSuperview];
	[closeTarget performSelector: closeAction withObject: nil afterDelay: 0];
}

-(void)dealloc
{
	[closeTarget release];
	[super dealloc];
}

-(void)onCloseTarget: (id)t action: (SEL)a
{
	closeTarget = [t retain];
	closeAction = a;
}

@end


@implementation App

-(void)doneWithMenu
{
	allowMenu = YES;
}

-(void)mouseUp:(struct __GSEvent *)e
{
	if( allowMenu ) {
		allowMenu = NO;
		id v = [[[PreviewWindow alloc] initWithImage: currentImage] autorelease];
		[window addSubview: v];
		[v onCloseTarget: self action: @selector(doneWithMenu)];
		[v showMenu];
	}
}

-(void)fetchWallpapers
{
	currentIndex = (currentIndex == 200)? 0: currentIndex+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://wallpaper.iappaday.com/wallpaper/%d.jpg",currentIndex]]];
	[get finishedTransferTarget: self action: @selector(gotWallpaper:)];
	[get performRequest];
}

-(void)setWallpaper: (UIImage*)img
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: img] autorelease];
	[bg setFrame: [window bounds]];
	[[window contentView] transition: 6 toView: bg];
	[currentImage release];
	currentImage = [img retain];
}

-(void)gotWallpaper: (NSData*)data
{
	if( data ) [self setWallpaper: [[[UIImage alloc] initWithData: data cache: NO] autorelease]];
	[self performSelector: @selector(fetchWallpapers) withObject: nil afterDelay: 6];
}

-(void)sendWallpaper: (id)data
{
	DataPoster *post = [DataPoster postToURL: [NSURL URLWithString: @"http://wallpaper.iappaday.com/wallpaper/save.php"]];
	[post sendData: data];
}

-(void)processWallpaperImage: (UIImage*)img
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSMutableData *pic = imageToData( img );
	[self performSelectorOnMainThread: @selector(sendWallpaper:) withObject: pic waitUntilDone: NO];
	[pool release];
}

-(void)startTheShow
{
	allowMenu = YES;
	[NSThread detachNewThreadSelector: @selector(processWallpaperImage:) toTarget: self withObject: [UIImage defaultDesktopImage] ];
	[self fetchWallpapers];
}

-(void)showStart
{
	UITransitionView *t = [[[UITransitionView alloc] initWithFrame: [window bounds]] autorelease];	
	[window setContentView: t];

	[self setWallpaper: [UIImage defaultDesktopImage]];

	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setTitle: @"Privacy Note"];
	[alert setBodyText: @"Your wallpaper will be shared with the world and you will see what others are using for theirs. If you are uncomfortable with this, exit now."];
	[alert addButtonWithTitle: @"Continue"];
	[alert setAlertSheetStyle: 1];
	[alert setDelegate: self];
	[alert presentSheetFromAboveView: [window contentView]];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Wallpaper" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: nil] autorelease];
	[s continueTarget: self action: @selector(showStart)];
	[window setContentView: s];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[self startTheShow];
	[sheet dismissAnimated: YES];
}

-(void)dealloc
{
	[currentImage release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	currentIndex = r() * 200;
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
