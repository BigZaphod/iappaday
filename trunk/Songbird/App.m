/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <MusicLibrary/MLTrackRep.h>

float r()
{
        return random() / (float)RAND_MAX;
}

@implementation App
-(void)openMouth
{
	[mouth setOrigin: CGPointMake(127,55)];
	[self performSelector: @selector(closeMouth) withObject: nil afterDelay: (1.5*r())];
	mouthClosed = NO;
}

-(void)closeMouth
{
	[mouth setOrigin: CGPointMake(127,45)];
	[self performSelector: @selector(closedMouth) withObject: nil afterDelay: r()];
}

-(void)closedMouth
{
	mouthClosed = YES;
}

-(void)gobble
{
	[self openMouth];
	[c setCurrentItem: gobble preservingRate:NO];
	[c play: nil];
}

-(void)startSong
{
	MLTrackRep *t = [q entityAtIndex: (r() * ([q countOfEntities] -1))];
	AVItem *song = [[AVItem alloc] initWithPath:[t path] error: nil];
	[c pause];
	[c setCurrentItem: song preservingRate:NO];
	float skip = 20 + (r() * 10);
	[c setCurrentTime: skip];	// skip 20 to 30 seconds into the song
	[c play: nil];
	terribleHackCuzImLazyAndTired++;
	[self performSelector: @selector(checkForFinishedSong:) withObject: [NSNumber numberWithInt: terribleHackCuzImLazyAndTired] afterDelay: [t duration]-skip];
}

-(void)changeTune
{
	[self gobble];
	canChangeTune = NO;
	playingMusic = YES;
	[self performSelector: @selector(startSong) withObject: nil afterDelay: 2];
	[self performSelector: @selector(tuneChangeAllowed) withObject: nil afterDelay: 20];
}

-(void)checkForFinishedSong: (NSNumber*)n
{
	if( terribleHackCuzImLazyAndTired == [n intValue] ) {
		[self changeTune];
	}
}

-(void)tuneChangeAllowed
{
	canChangeTune = YES;
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	turkeySpeed.x -= x * 20;
	if( canJump ) {
		if( fabs(y) > 0.3 ) turkeySpeed.y -= y * 50;
		if( fabs(z) > 0.3 && fabs(z) < 0.45 ) turkeySpeed.y += z * 60;
	}
	if( fabs(x) > 0.4 && canChangeTune ) {
		[self changeTune];
	}
}

-(void)mouseDown:(struct __GSEvent *)blah
{
	if( canChangeTune )
		[self changeTune];
}

-(void)runLoop
{
	CGPoint p = [turkey origin];
	p.x += turkeySpeed.x;
	p.y += turkeySpeed.y;

	turkeySpeed.x *= 0.9;
	turkeySpeed.y *= 0.9;
	turkeySpeed.y += 6;

	if( p.x < 0 ) {
		p.x = 0;
		turkeySpeed.x *= -0.98;
	}
	if( p.x > 172 ) {
		p.x = 172;
		turkeySpeed.x *= -0.98;
	}
	if( p.y >= 305 ) {
		p.y = 305;
		turkeySpeed.y = 0;
		canJump = YES;
	} else {
		canJump = NO;
	}

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve:3];
	[UIView setAnimationDuration:0.05];
	[turkey setOrigin: p];
	if( playingMusic && mouthClosed ) {
		[self openMouth];
	}
	[UIView endAnimations];

	[self performSelector: @selector(runLoop) withObject: nil afterDelay: 0.05];
}

-(void)showTurkey
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	turkey = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"turkey.png"]];
	mouth = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"mouth.png"]];

	[turkey addSubview: mouth];
	[self closeMouth];
	[turkey setOrigin: CGPointMake(80,305)];

	[bg addSubview: turkey];
	[window setContentView: bg];

	[self gobble];
	[self performSelector: @selector(tuneChangeAllowed) withObject: nil afterDelay: 3];
	[self runLoop];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Songbird" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showTurkey)];
	[window setContentView: s];
}

-(void)dealloc
{
	[mouth release];
	[turkey release];
	[window release];
	[gobble release];
	[c release];
	[ml release];
	[q release];
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

	c = [[AVController avController] retain];

	gobble = [[AVItem avItemWithPath:[[NSBundle mainBundle] pathForResource:@"gobble" ofType:@"mp4" inDirectory:@"/"] error: nil] retain];

	// Music Library Code inspired by Music Quiz By: brian whitman brian.whitman@variogr.am http://variogr.am/

	// Set up the music library
	ml = [MusicLibrary sharedMusicLibrary];

	// A blank query gets all tracks
	q = [[MLQuery alloc] init];

	//[self showSplash];
	[self showTurkey];
}

@end
