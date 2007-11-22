/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "MenuView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

float r()
{
	return random() / (float)RAND_MAX;
}

@interface Letter : UIImageView {
	NSString *character;
}
-(NSString*)character;
@end

@implementation Letter
-(NSString*)character { return character; }
-(void)dealloc
{
	[character release];
	[super dealloc];
}
-(id)initWithCharacter: (NSString*)c andBackground: (int)b
{
	[self initWithImage: [UIImage applicationImageNamed:[NSString stringWithFormat: @"letter%d.png", b]]];

	UITextLabel *txt = [[[UITextLabel alloc] initWithFrame: CGRectMake(2,3,52,55)] autorelease];
	[txt setCentersHorizontally: YES];
	[txt setText: c];

        float alphaColor[] = { 0, 0, 0, 0 };
        float shadowColor[] = { 0, 0, 0, 0.3 };

        struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:48];
        [txt setFont: font];
        [txt setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
        [txt setShadowColor:  CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor)];
        [txt setShadowOffset: CGSizeMake(2,2)];
	[self addSubview: txt];

	character = [c retain];

	return self;
}
@end

extern CGPoint GSEventGetLocationInWindow(struct __GSEvent*);

@implementation App

-(void)renderLetters
{
	int num;
	for( num=0; num<[letters count]; num++ ) {
		id l = [letters objectAtIndex: num];
		if( l != grabbedLetter )
			[l setOrigin: CGPointMake(70*num,0)];
	}

}

-(void)makeLetters: (NSString*)str
{
	[letters removeAllObjects];
	[letterContainer removeFromSuperview];
	[letterContainer release];
	letterContainer = [[UIView alloc] init];

	int len;
	for( len=0; len<MIN([str length],6); len++ ) {
		id c = [[str substringWithRange: NSMakeRange(len,1)] uppercaseString];
		Letter *l1 = [[[Letter alloc] initWithCharacter: c andBackground: len+1] autorelease];
		[letterContainer addSubview: l1];
		[letters addObject: l1];
	}

	[letterContainer setRotationBy: 90];
	[letterContainer setOrigin: CGPointMake(190,35 + ((6-len) * 35))];
	[[window contentView] addSubview: letterContainer];
}

-(int)letterIndexFromPoint: (CGPoint)p
{
	float offset = [letterContainer origin].y;
	int num;
	for( num = [letters count]-1; num>=0; num-- ) {
		if( p.y-offset >= 70*num )
			return num;
	}
	return 0;
}

-(void)mouseDown:(struct __GSEvent *)blah
{
	if( playing ) {
		CGPoint p = GSEventGetLocationInWindow(blah);
		grabbedLetter = [letters objectAtIndex: [self letterIndexFromPoint: p]];
	}
}

-(void)mouseDragged:(struct __GSEvent *)blah
{
	if( grabbedLetter ) {
		CGPoint p = GSEventGetLocationInWindow(blah);
		CGPoint o = [grabbedLetter origin];
		float offset = [letterContainer origin].y;
		[grabbedLetter setOrigin: CGPointMake(p.y-offset-30,o.y)];
		int index = [self letterIndexFromPoint: p];
		[letters removeObject: grabbedLetter];
		[letters insertObject: grabbedLetter atIndex: index];
		[self renderLetters];
	}
}

-(BOOL)isCorrect
{
	NSMutableString *str = [[[NSMutableString alloc] init] autorelease];
	int num;
	for( num=0; num<[letters count]; num++ )
		[str appendString: [[letters objectAtIndex: num] character]];
	return [str caseInsensitiveCompare: correctAnswer] == NSOrderedSame;
}

-(void)checkAnswer
{
	if( [self isCorrect] ) {
		playing = NO;
		UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
		[alert setDelegate: self];
		[alert setTitle: @"Correct!"];
		[alert setBodyText: [correctAnswer lowercaseString]];
		[alert addButtonWithTitle: @"Play Again"];
		[alert setDimsBackground: NO];
		[alert popupAlertAnimated: NO];
		[alert setRotationBy: 90];
	}
}

-(void)mouseUp:(struct __GSEvent *)blah
{
	if( playing ) {
		grabbedLetter = nil;
		[self renderLetters];
		[self checkAnswer];
	}
}

-(void)scrambleLetters
{
	int i, n = [letters count];
	for( i=0; i<n; i++ ){
		int destinationIndex = random() % (n - i) + i;
		[letters exchangeObjectAtIndex:i withObjectAtIndex:destinationIndex];
	}
}

-(NSString*)randomWord
{
	NSString *data = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"wordlist" ofType:nil inDirectory:@"/"]];
	id words = [data componentsSeparatedByString: @"\n"];
	return [words objectAtIndex: (int)(r()*([words count])-1)];
}

-(void)newWord
{
	NSString *word = [self randomWord];
	[self makeLetters: word];
	[correctAnswer release];
	correctAnswer = [word retain];
	while( [self isCorrect] )
		[self scrambleLetters];
	[self renderLetters];
	playing = YES;
}

-(void)showGame
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	[window setContentView: bg];
	[self newWord];
}

-(void)showDigg
{
	[self openURL: [NSURL URLWithString: @"http://digg.com/apple/iApp_a_Day"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Mixup" body: @"Turn your iPhone or iPod on its side and decode the english word."] autorelease];
	[menu addButtonWithTitle: @"Start The Game" target: self action: @selector(showGame)];
	[menu addButtonWithTitle: @"Digg iApp-a-Day!" target: self action: @selector(showDigg)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Mixup" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: NO];
	[self newWord];
}

-(void)dealloc
{
	[correctAnswer release];
	[letterContainer release];
	[letters release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );

        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	letters = [[NSMutableArray alloc] init];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
