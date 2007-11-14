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

static NSString *soundPath = @"/tmp/whisper.amr";

@implementation App

float r()
{
	return random() / (float)RAND_MAX;
}

-(void)showScreen
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];

	UIPushButton *btn1 = [[[UIPushButton alloc] initWithImage: [UIImage applicationImageNamed:@"record1.png"]] autorelease];
	[btn1 setImage: [UIImage applicationImageNamed:@"record2.png"] forState: 1];
	[btn1 setOrigin: CGPointMake(22,364)];
	[btn1 addTarget: self action: @selector(recordingPrep) forEvents: 1<<6];
	[bg addSubview: btn1];

	UIPushButton *btn2 = [[[UIPushButton alloc] initWithImage: [UIImage applicationImageNamed:@"listen1.png"]] autorelease];
	[btn2 setImage: [UIImage applicationImageNamed:@"listen2.png"] forState: 1];
	[btn2 setOrigin: CGPointMake(22,412)];
	[btn2 addTarget: self action: @selector(listenToSecrets) forEvents: 1<<6];
	[bg addSubview: btn2];

	[window setContentView: bg];
}

-(void)playBack
{
	AVItem *s = [AVItem avItemWithPath: soundPath error: nil];
	[ac setCurrentItem: s preservingRate:YES];
	[ac play: nil];
	[self performSelector: @selector(doneWithPlayBack) withObject: nil afterDelay: 9];
}

-(void)downloadSecret
{
	if( soundCounter >= 50 ) {
		soundCounter = 0;
	} else {
		soundCounter++;
	}
	DataGetter *get = [[[DataGetter alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://whisper.iappaday.com/whisper/%d.amr",soundCounter]] inView: [window contentView] toFileAtPath: soundPath] autorelease];
	[get finishedTransferTarget: self action: @selector(playBack)];
}

-(void)doneWithPlayBack
{
	if( playing )
		[self downloadSecret];
}

-(void)listenToSecrets
{
	UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
	[sheet addButtonWithTitle: @"Stop Listening"];
	[sheet setDelegate: self];
	[sheet presentSheetInView: [window contentView]];
	playing = YES;
	[self downloadSecret];
}

-(void)doneUploading
{
	[[NSFileManager defaultManager] removeFileAtPath: soundPath handler: nil];
	[self showScreen];
}

-(void)stopRecording
{
	[recorder stop];
	DataPoster *poster = [[[DataPoster alloc] initWithURL: [NSURL URLWithString: [NSString stringWithFormat:@"http://whisper.iappaday.com/whisper/share.php"]] inView: recordingView] autorelease];
	[poster finishedTransferTarget: self action: @selector(doneUploading)];
	[poster sendData: [NSData dataWithContentsOfFile: soundPath]];
}

-(void)startRecording
{
	[window setContentView: recordingView];

	[recorder activate: nil];
	[recorder setFilePath: [NSURL URLWithString: soundPath]];
	[recorder start];

	[self performSelector: @selector(stopRecording) withObject: nil afterDelay: 8.5];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( [sheet buttonCount] == 1 ) {
		playing = NO;
		[ac setCurrentItem: nil];
	} else if( button == 1 ) {
		[self startRecording];
	}
	[sheet dismissAnimated: YES];
}

-(void)recordingPrep
{
	UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
	[sheet setTitle: @"An Eight Second Secret"];
	[sheet setBodyText: @"After pressing the record button, hold the phone as if you are on a call and speak normally. Please be considerate and aware that your recordings are uploaded randomly to people of all ages and can be associated with your phone's current internet address. You are not anonymous, technically speaking."];
	[sheet addButtonWithTitle: @"Record"];
	[sheet addButtonWithTitle: @"Nevermind"];
	[sheet setDelegate: self];
	[sheet popupAlertAnimated: YES];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Whisper" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: @"UnitOneNine <Lee@UnitOneNine.com>"] autorelease];
	[s continueTarget: self action: @selector(showScreen)];
	[window setContentView: s];
}

-(void)dealloc
{
	[ac release];
	[recordingView release];
	[recorder release];
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

	recorder = [[AVRecorder alloc] init];
	recordingView = [[UIImageView alloc] initWithImage:[UIImage applicationImageNamed:@"recording.jpg"]];
	soundCounter = (int)(r() * 50);
	ac = [[AVController avController] retain];

	[self showSplash];
}

@end
