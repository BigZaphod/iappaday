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
#import "DataGetter.h"
#import "SimpleWebView.h"
#import <UIKit/UIView-Geometry.h>

@implementation App

float r()
{
	return random() / (float)RAND_MAX;
}

-(void)takePhoto
{
	CaptureView *v = [[[CaptureView alloc] init] autorelease];
	[v pictureDataTarget: self action: @selector(gotPictureData:)];
	[v menuTarget: self action: @selector(showMenu)];
	[window setContentView: v];
}

-(void)gotQuest: (NSData *)data
{
	if( !data || ![data length] ) {
		[self showMenu];
		return;
	}

	NSString *quest = [[[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding] autorelease];

	UIAlertSheet *alert = [[UIAlertSheet alloc] init];
	[alert setDelegate: self];
	[alert setTitle: @"Current Mission:"];
	[alert setBodyText: [NSString stringWithFormat: @"Photograph %s", [quest cString]]];
	[alert addButtonWithTitle: @"Accept"];
	[alert addButtonWithTitle: @"Decline"];
	[alert setTag: 1];
	[alert popupAlertAnimated: YES];
}

-(void)startQuest
{
	DataGetter *get =[[[DataGetter alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat: @"http://quest.iappaday.com/quest/current.txt?r=%f", r()]] inView: [window contentView]] autorelease];
	[get finishedTransferTarget: self action: @selector(gotQuest:)];
}

-(void)showWhatOthersHaveFound
{
	SimpleWebView *web = [[[SimpleWebView alloc] initWithFrame: [window bounds] andURL: [NSURL URLWithString:@"http://quest.iappaday.com/quest/"]] autorelease];
	[web menuTarget: self action: @selector(showMenu)];
	[window setContentView: web];
}

-(void)gotPictureData: (NSData*)output
{
	picture = [output retain];

	UIImage *img = [[[UIImage alloc] initWithData: output cache: YES] autorelease];
	UIImageView *v = [[[UIImageView alloc] initWithImage: img] autorelease];
	[window setContentView: v];

	UIAlertSheet *alert = [[UIAlertSheet alloc] init];
	[alert setDelegate: self];
	[alert setBodyText: @"Please don't be obscene. These images may be seen by people of all ages. It is illegal in most countries to knowingly expose a minor to indecent content."];
	[alert setAlertSheetStyle:1];
	[alert addButtonWithTitle: @"Publish"];
	[alert setDestructiveButton: [alert addButtonWithTitle: @"Retake"]];
	[alert setTag: 0];
	[alert presentSheetInView: v];
}

-(void)showQuestTV
{
	[self openURL: [NSURL URLWithString: @"http://quest.iappaday.com/quest/tv.html"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Quest" body: nil] autorelease];
	[menu addButtonWithTitle: @"Start The Mission" target: self action: @selector(startQuest)];
	[menu addButtonWithTitle: @"View Everyone's Results" target: self action: @selector(showWhatOthersHaveFound)];
	[menu addButtonWithTitle: @"Quest TV" target: self action: @selector(showQuestTV)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Quest" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( [sheet tag] == 0 ) {
		if( button == 2 ) {
			[picture release];
			picture = nil;
			[self takePhoto];
		} else {
			PicturePoster *pp = [[[PicturePoster alloc] initWithURL: [NSURL URLWithString: @"http://quest.iappaday.com/quest/submit.php"] inView: window] autorelease];
			[pp finishedTransferTarget: self action: @selector(showWhatOthersHaveFound)];
			[pp sendPictureData: picture];
			[window addSubview: pp];
			[picture release];
			picture = nil;
		}
	} else if( [sheet tag] == 1 ) {
		if( button == 1 ) {
			[self takePhoto];
		} else {
			[self showMenu];
		}
	}

	[sheet dismissAnimated: YES];
	[sheet release];
}

-(void)dealloc
{
	if( picture ) [picture release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
