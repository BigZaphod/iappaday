/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "MenuView.h"
#import "CaptureView.h"
#import "PicturePoster.h"
#import "SimpleWebView.h"
#import <UIKit/UIView-Geometry.h>

@implementation App

-(void)takePhoto
{
	CaptureView *v = [[[CaptureView alloc] init] autorelease];
	[v pictureDataTarget: self action: @selector(gotPictureData:)];
	[v menuTarget: self action: @selector(showMenu)];
	[window setContentView: v];
}

-(void)showWhatOthersHaveDone
{
	SimpleWebView *web = [[[SimpleWebView alloc] initWithFrame: [window bounds] andURL: [NSURL URLWithString:@"http://burp.iappaday.com/burp/"]] autorelease];
	[web menuTarget: self action: @selector(showMenu)];
	[window setContentView: web];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 3 ) {
		[picture release];
		picture = nil;
		[self takePhoto];
	} else {
		// button == naugty or nice parameter
		PicturePoster *pp = [[[PicturePoster alloc] initWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://burp.iappaday.com/burp/ate.php?p=%d",button]] inView: window] autorelease];
		[pp finishedTransferTarget: self action: @selector(showWhatOthersHaveDone)];
		[pp sendPictureData: picture];
		[window addSubview: pp];
		[picture release];
		picture = nil;
	}

	[sheet dismissAnimated: YES];
	[sheet release];
}

-(void)gotPictureData: (NSData*)output
{
	picture = [output retain];

	UIImage *img = [[[UIImage alloc] initWithData: output cache: YES] autorelease];
	UIImageView *v = [[[UIImageView alloc] initWithImage: img] autorelease];
	[window setContentView: v];

	UIAlertSheet *alert = [[UIAlertSheet alloc] init];
	[alert setDelegate: self];
	[alert setTitle: @"How would you rank this food?"];
	[alert setBodyText: @"Please don't be obscene. These images may be seen by people of all ages. It is illegal in most countries to knowingly expose a minor to indecent content."];
	[alert setAlertSheetStyle:1];
	[alert addButtonWithTitle: @"Naughty"];
	[alert addButtonWithTitle: @"Nice"];
	[alert setDestructiveButton: [alert addButtonWithTitle: @"Retake"]];
	[alert presentSheetInView: v];
}

-(void)showBurpTV
{
	[self openURL: [NSURL URLWithString: @"http://burp.iappaday.com/burp/tv.html"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: nil body: @"Share your meal with the world."] autorelease];
	[menu addButtonWithTitle: @"Photograph Your Meal" target: self action: @selector(takePhoto)];
	[menu addButtonWithTitle: @"View Latest Meals" target: self action: @selector(showWhatOthersHaveDone)];
	[menu addButtonWithTitle: @"Burp TV" target: self action: @selector(showBurpTV)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Burp" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

-(void)dealloc
{
	if( picture ) [picture release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
