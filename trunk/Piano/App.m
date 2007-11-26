/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "TonePlayer.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Gestures.h>
#import <UIKit/UIView-Animation.h>

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);
extern CGPoint GSEventGetInnerMostPathPosition(struct __GSEvent*);
extern CGPoint GSEventGetOuterMostPathPosition(struct __GSEvent*);

#define KEYBOARDnotes 12

@interface KeyboardView : UIImageView {
	TonePlayer *player;
	Tone *notes[(KEYBOARDnotes)];
}
@end

@implementation KeyboardView
-(void)dealloc
{
	int i;
	for( i=0; i<(KEYBOARDnotes); i++ )
		[notes[i] release];
	[player release];
	[super dealloc];
}

-(id)initWithTonePlayer: (TonePlayer*)p
{
	[super initWithImage: [UIImage applicationImageNamed:@"keyboard.jpg"]];
	[self setEnabledGestures: 1];
	[self setGestureDelegate: self];
	player = [p retain];

	// white keys
	notes[0] = [[Tone toneWithFrequency: 261.626] retain];	// C4  (middle C)
	notes[1] = [[Tone toneWithFrequency: 293.665] retain];	// D4
	notes[2] = [[Tone toneWithFrequency: 329.628] retain];	// E4
	notes[3] = [[Tone toneWithFrequency: 349.228] retain];	// F4
	notes[4] = [[Tone toneWithFrequency: 391.995] retain];	// G4
	notes[5] = [[Tone toneWithFrequency: 440.000] retain];	// A4
	notes[6] = [[Tone toneWithFrequency: 493.883] retain];	// B4

	// black keys
	notes[7] = [[Tone toneWithFrequency: 277.183] retain];	// C#4
	notes[8] = [[Tone toneWithFrequency: 311.127] retain];	// D#4
	notes[9] = [[Tone toneWithFrequency: 369.994] retain];	// F#4
	notes[10]= [[Tone toneWithFrequency: 415.305] retain];	// G#4
	notes[11]= [[Tone toneWithFrequency: 466.164] retain];	// A#4

	return self;
}

-(Tone*)toneAt: (CGPoint)p
{
	// black keys
	if( p.x > 130 ) {
		if( p.y > 405 && p.y < 442 ) return notes[11];
		if( p.y > 323 && p.y < 363 ) return notes[10];
		if( p.y > 243 && p.y < 285 ) return notes[9];
		if( p.y > 127 && p.y < 166 ) return notes[8];
		if( p.y > 43 && p.y < 78 ) return notes[7];
	}

	// white keys
	if( p.y > 411 ) return notes[6];
	if( p.y > 343 ) return notes[5];
	if( p.y > 274 ) return notes[4];
	if( p.y > 206 ) return notes[3];
	if( p.y > 136 ) return notes[2];
	if( p.y > 66 ) return notes[1];
	return notes[0];
}

-(void)playSingleTone: (Tone*)tone
{
	NSArray *tones = [player playingTones];
	if( ![tones containsObject: tone] )
		[player addTone: tone];
	int i;
	for( i=0; i<[tones count]; i++ ) {
		id o = [tones objectAtIndex: i];
		if( ![o isEqual: tone] )
			[player removeTone: o];
	}
}

-(void)playOnlyTone: (Tone*)tone1 and: (Tone*)tone2
{
	NSArray *tones = [player playingTones];
	if( ![tones containsObject: tone1] )
		[player addTone: tone1];
	if( ![tones containsObject: tone2] )
		[player addTone: tone2];
	int i;
	for( i=0; i<[tones count]; i++ ) {
		id o = [tones objectAtIndex: i];
		if( !([o isEqual: tone1] || [o isEqual: tone2]) )
			[player removeTone: o];
	}
}

-(void)mouseUp: (struct __GSEvent*)e
{
	[player removeAllTones];
}

-(void)mouseDown: (struct __GSEvent*)e
{
	[self playSingleTone: [self toneAt: GSEventGetLocationInWindow(e)]];
}

-(void)mouseDragged: (struct __GSEvent*)e
{
	[self playSingleTone: [self toneAt: GSEventGetLocationInWindow(e)]];
}

- (void)gestureStarted:(struct __GSEvent *)e
{
}

- (void)gestureEnded:(struct __GSEvent *)e
{
	[self playSingleTone: [self toneAt: GSEventGetLocationInWindow(e)]];
}

- (void)gestureChanged:(struct __GSEvent *)e
{
	CGPoint p1 = GSEventGetInnerMostPathPosition(e);
	CGPoint p2 = GSEventGetOuterMostPathPosition(e);
	[self playOnlyTone: [self toneAt: p1] and: [self toneAt: p2]];
}

@end


@implementation App

-(void)showKeyboard
{
	player = [[TonePlayer alloc] init];
	KeyboardView *keyboard = [[[KeyboardView alloc] initWithTonePlayer: player] autorelease];
	[window setContentView: keyboard];
	[player play];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Piano" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showKeyboard)];
	[window setContentView: s];
}

-(void)dealloc
{
	[player release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	[UIHardware _setStatusBarHeight:0.0f];
	[self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
