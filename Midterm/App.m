/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "DataGetter.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

static NSString *whisperPath = @"/tmp/whisper.amr";

@implementation App

float r()
{
	return random() / (float)RAND_MAX;
}

-(void)playWhisper: (NSData*)data
{
	[data writeToFile: whisperPath atomically: YES];
	AVItem *s = [AVItem avItemWithPath: whisperPath error: nil];
	[ac setCurrentItem: s preservingRate:YES];
	[ac play: nil];
}

-(void)showQuestImage: (NSData*)data
{
	[questImage setImage: [[[UIImage alloc] initWithData: data cache: NO] autorelease]];
}

-(void)showGraffiti: (NSData*)data
{
	NSString *txt = [NSString stringWithCString: [data bytes] length: [data length] ];
	id parts = [txt componentsSeparatedByString: @"\n"];
	if( parts && [parts count] == 4 ) {
		float txtColor[] = { r(), r(), r(), 1 };
		[graffitiText setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)];
		[graffitiText setText: [parts objectAtIndex:3]];
	}
}

-(void)downloadWhisper
{
	whisperCounter = (whisperCounter > 50)? 0: whisperCounter+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://whisper.iappaday.com/whisper/%d.amr",whisperCounter]]];
	[get finishedTransferTarget: self action: @selector(playWhisper:)];
	[self performSelector: @selector(downloadWhisper) withObject: nil afterDelay: 9];
}

-(void)downloadQuestImage
{
	questCounter = (questCounter > 75)? 0: questCounter+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://quest.iappaday.com/quest/random/%d.jpg",questCounter]]];
	[get finishedTransferTarget: self action: @selector(showQuestImage:)];
	[self performSelector: @selector(downloadQuestImage) withObject: nil afterDelay: 10];
}

-(void)downloadGraffiti
{
	graffitiCounter = (graffitiCounter > 100)? 0: graffitiCounter+1;
	DataGetter *get = [DataGetter dataWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://graffiti.iappaday.com/graffiti/%d.txt",graffitiCounter]]];
	[get finishedTransferTarget: self action: @selector(showGraffiti:)];
	[self performSelector: @selector(downloadGraffiti) withObject: nil afterDelay: 6];
}

-(void)run
{
	[self downloadWhisper];
	[self downloadQuestImage];
	[self downloadGraffiti];
}

-(void)showScreen
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"bg.png"]] autorelease];
	[bg addSubview: questImage];
	[bg addSubview: graffitiText];
	[window setContentView: bg];
	[self run];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Midterm" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: nil] autorelease];
	[s continueTarget: self action: @selector(showScreen)];
	[window setContentView: s];
}

-(void)dealloc
{
	[questImage release];
	[graffitiText release];
	[ac release];
	[[NSFileManager defaultManager] removeFileAtPath: whisperPath handler: nil];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 0, 0, 0, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	whisperCounter = (int)(r() * 50);
	questCounter = (int)(r() * 75);
	graffitiCounter = (int)(r() * 100);

	ac = [[AVController avController] retain];
	questImage = [[UIImageView alloc] init];
	graffitiText = [[UITextLabel alloc] initWithFrame: CGRectMake(0,0,[window bounds].size.width,50)];
        struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Marker Felt" traits:0 size:40];
	float alphaColor[] = { 0, 0, 0, 0 };
	[graffitiText setFont: font];
	[graffitiText setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[graffitiText setCentersHorizontally: YES];

	[questImage setOrigin: CGPointMake(35,38)];
	[graffitiText setOrigin: CGPointMake(0,390)];

	[self showSplash];
}

@end
