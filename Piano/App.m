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

#define KEYBOARDnotes 14

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

	const float a = 0.01;
	const float d = 0.01;
	const float s = 0.8;
	const float r = 0.03;

	// white keys
	notes[0] = [[Tone toneWithFrequency: 261.626 attack: a decay: d sustain: s release: r] retain];	// C4  (middle C)
	notes[1] = [[Tone toneWithFrequency: 293.665 attack: a decay: d sustain: s release: r] retain];	// D4
	notes[2] = [[Tone toneWithFrequency: 329.628 attack: a decay: d sustain: s release: r] retain];	// E4
	notes[3] = [[Tone toneWithFrequency: 349.228 attack: a decay: d sustain: s release: r] retain];	// F4
	notes[4] = [[Tone toneWithFrequency: 391.995 attack: a decay: d sustain: s release: r] retain];	// G4
	notes[5] = [[Tone toneWithFrequency: 440.000 attack: a decay: d sustain: s release: r] retain];	// A4
	notes[6] = [[Tone toneWithFrequency: 493.883 attack: a decay: d sustain: s release: r] retain];	// B4
	notes[7] = [[Tone toneWithFrequency: 523.251 attack: a decay: d sustain: s release: r] retain];	// C5

	// black keys
	notes[8] = [[Tone toneWithFrequency: 277.183 attack: a decay: d sustain: s release: r] retain];	// C#4
	notes[9] = [[Tone toneWithFrequency: 311.127 attack: a decay: d sustain: s release: r] retain];	// D#4
	notes[10] = [[Tone toneWithFrequency: 369.994 attack: a decay: d sustain: s release: r] retain];	// F#4
	notes[11]= [[Tone toneWithFrequency: 415.305 attack: a decay: d sustain: s release: r] retain];	// G#4
	notes[12]= [[Tone toneWithFrequency: 466.164 attack: a decay: d sustain: s release: r] retain];	// A#4
	notes[13]= [[Tone toneWithFrequency: 554.365 attack: a decay: d sustain: s release: r] retain];	// C#5

	return self;
}

-(Tone*)toneAt: (CGPoint)p
{
	// black keys
	if( p.x > 120 ) {
		if( p.y > 455 ) return notes[13];
		if( p.y > 344 && p.y < 392 ) return notes[12];
		if( p.y > 276 && p.y < 325 ) return notes[11];
		if( p.y > 210 && p.y < 257 ) return notes[10];
		if( p.y > 104 && p.y < 154 ) return notes[9];
		if( p.y > 29 && p.y < 80 ) return notes[8];
	}

	// white keys
	if( p.y > 421 ) return notes[7];
	if( p.y > 361 ) return notes[6];
	if( p.y > 300 ) return notes[5];
	if( p.y > 240 ) return notes[4];
	if( p.y > 181 ) return notes[3];
	if( p.y > 119 ) return notes[2];
	if( p.y > 59 ) return notes[1];
	return notes[0];
}

-(void)playSingleTone: (Tone*)tone
{
	if( ![player playingTone: tone] )
		[player addTone: tone];

	int i;
	NSArray *tones = [player playingTones];
	for( i=0; i<[tones count]; i++ ) {
		id o = [tones objectAtIndex: i];
		if( ![o isEqual: tone] )
			[player removeTone: o];
	}
}

-(void)playOnlyTone: (Tone*)tone1 and: (Tone*)tone2
{
	if( ![player playingTone: tone1] )
		[player addTone: tone1];
	if( ![player playingTone: tone2] )
		[player addTone: tone2];

	int i;
	NSArray *tones = [player playingTones];
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
