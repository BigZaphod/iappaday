/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <WebCore/WebFontCache.h>

float r()
{
	return random() / (float)RAND_MAX;
}

@implementation LetterPickerView
-(void)dealloc
{
	[letters release];
	[target release];
	[picker release];
	[view release];
	[super dealloc];
}
-(void)guessTarget: (id)t action: (SEL)s
{
	target = [t retain];
	action = s;
}
- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 0 ) {
		[target performSelector: action withObject: [letters objectAtIndex: [picker selectedRowForColumn:0]] afterDelay: 0];
	}
	[self removeFromSuperview];
}
-(id)initInView: (UIView*)v
{
	CGRect b = [v bounds];
	[super initWithFrame: b];

	CGSize s = [UIPickerView defaultSize];
	CGSize bs = [UINavigationBar defaultSize];

	UINavigationBar *nav = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,b.size.height-bs.height,bs.width,bs.height)] autorelease];
	[nav setBarStyle: 1];
	[nav showButtonsWithLeftTitle: @"Not To Be" rightTitle: @"Could Be"];
	[nav setDelegate: self];
	[self addSubview: nav];

	letters = [[NSMutableArray alloc] init];

	picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0,b.size.height-bs.height-s.height, b.size.width, s.height)];
	[picker setDelegate: self];
	[self addSubview: picker];

	view = [v retain];
	return self;
}
-(int)numberOfColumnsInPickerView:(id)v
{
	return 1;
}
-(int)pickerView:(id)v numberOfRowsInColumn:(int)c
{
	return [letters count];
}
-(id)pickerView:(id)v tableCellForRow:(int)r inColumn:(int)c
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	[cell setAlignment: 2];
	[cell setTitle: [letters objectAtIndex: r]];
	return cell;
}
-(void)pickerViewLoaded:(id)v
{
	UIView *bar = [[[UIView alloc] initWithFrame: [v selectionBarRect]] autorelease];
	float bgColor[] = { 0.2, 0.2, 0.2, 1 };
	[bar setAlpha: 0.2];
	[bar setEnabled: NO];
	[bar setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[v addSubview: bar];

}
-(void)showChooserWithoutLetters: (NSArray*)guessed
{
	[view addSubview: self];
	[letters removeAllObjects];
	char c;
	for( c='A'; c<='Z'; c++ ) {
		[letters addObject: [NSString stringWithFormat: @"%c", c]];
	}
	[letters removeObjectsInArray: guessed];
	[picker reloadData];
}
@end



@implementation App

-(void)mouseUp:(struct __GSEvent *)blah
{
	[letterPicker showChooserWithoutLetters: guessedLetters];
}

-(void)generateNewPhrase
{
	NSString *file = [NSString stringWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"quotes" ofType:@"txt" inDirectory:@"/"]];
	id phrases = [file componentsSeparatedByString: @"------------------\n"];
	[goalPhrase release];
	goalPhrase = [[phrases objectAtIndex: (int)(r()*([phrases count]-1))] retain];
	[guessedLetters removeAllObjects];
}

-(BOOL)renderPhrase
{
	NSMutableString *phrase = [[NSMutableString alloc] init];
	int i;
	BOOL finished = YES;
	for( i=0; i<[goalPhrase length]; i++ ) {
		unsigned short c = [goalPhrase characterAtIndex:i];
		id cc = [[NSString stringWithFormat: @"%c", c] uppercaseString];
		if( [guessedLetters containsObject: cc] || !isalpha(c) ) {
			[phrase appendFormat: @"%c", c];
		} else {
			[phrase appendString: @"_"];
			finished = NO;
		}
	}
	[words setText: phrase];
	return finished;
}

-(void)renderTheBard
{
	[leg1 setAlpha: wrong > 5];
	[leg2 setAlpha: wrong > 4];
	[arm1 setAlpha: wrong > 3];
	[arm2 setAlpha: wrong > 2];
	[body setAlpha: wrong > 1];
	[head setAlpha: wrong > 0];
	[dead setAlpha: wrong == 6];
}

-(void)guessedLetter: (NSString*)letter
{
	[guessedLetters addObject: letter];
	if( [[goalPhrase uppercaseString] rangeOfString: [letter uppercaseString]].location == NSNotFound ) {
		wrong++;
		[self renderTheBard];
		if( wrong == 6 ) {
			UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
			[sheet setTitle: @"The Bard Has Perished"];
			[sheet setBodyText: @"A foolish thought, to say a sorry sight, are you. You have lost!"];
			[sheet addButtonWithTitle: @"Play Again"];
			[sheet setDelegate: self];
			[sheet popupAlertAnimated: YES];
		}
	} else {
		if( [self renderPhrase] ) {
			UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
			[sheet setTitle: @"Long Live The Bard!"];
			[sheet setBodyText: @"Sweets to the sweet, farewell!\nYou have won!"];
			[sheet addButtonWithTitle: @"Play Again"];
			[sheet setDelegate: self];
			[sheet popupAlertAnimated: YES];
		}
	}
}

-(void)startGame
{
	wrong = 0;
	[self generateNewPhrase];
	[self renderPhrase];
	[self renderTheBard];
}

-(void)buildTheBard
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"Default.png"]] autorelease];

	UIImageView *noose = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"noose.png"]] autorelease];
	[bg addSubview: noose];
	[noose setOrigin: CGPointMake(15,15)];

	arm1 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"arm1.png"]];
	[arm1 setOrigin: CGPointMake(96,140)];

	arm2 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"arm2.png"]];
	[arm2 setOrigin: CGPointMake(157,144)];

	leg1 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"leg1.png"]];
	[leg1 setOrigin: CGPointMake(140,205)];

	leg2 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"leg2.png"]];
	[leg2 setOrigin: CGPointMake(92,207)];

	body = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"body.png"]];
	[body setOrigin: CGPointMake(88,88)];

	head = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"head.png"]];
	[head setOrigin: CGPointMake(70,10)];

	dead = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed: @"headdead.png"]];
	[dead setOrigin: CGPointMake(70,10)];

	[noose addSubview: head];
	[noose addSubview: dead];
	[noose addSubview: body];
	[noose addSubview: leg1];
	[noose addSubview: leg2];
	[noose addSubview: arm1];
	[noose addSubview: arm2];

	words = [[UITextView alloc] initWithFrame: CGRectMake(22,298,290,155)];
	float bgColor[] = { 1, 1, 1, 0 };
	[words setEnabled: NO];
	[words setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[words setTextFont: @"Monospace"];
	[words setTextSize: 23];
	[bg addSubview: words];

	[window setContentView: bg];

	[self startGame];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Bard" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: @"Greg Nichols <greg@slarty.org>"] autorelease];
	[s continueTarget: self action: @selector(buildTheBard)];
	[window setContentView: s];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[self startGame];
	[sheet dismissAnimated: YES];
}

-(void)dealloc
{
	[guessedLetters release];
	[goalPhrase release];
	[words release];
	[arm1 release];
	[arm2 release];
	[leg1 release];
	[leg2 release];
	[body release];
	[head release];
	[dead release];
	[letterPicker release];
	[window release];
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

	guessedLetters = [[NSMutableArray alloc] init];
	letterPicker = [[LetterPickerView alloc] initInView: window];
	[letterPicker guessTarget: self action: @selector(guessedLetter:)];

	[self showSplash];
}

@end
