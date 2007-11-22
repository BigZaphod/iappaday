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

float r()
{
	return random() / (float)RAND_MAX;
}

@interface Ice : UIImageView {
	int lifetime;
	int growtime;
	int age;
	float dropSpeed;
}
@end

@implementation Ice
-(id)initWithLifetime: (int)timesteps
{
	[self initWithImage: [UIImage applicationImageNamed:[NSString stringWithFormat: @"ice%d.png",(int)(r()*6)]]];
	float y = r() * (480 - [[self image] size].height);
	[self setOrigin: CGPointMake(320+169,y)];
	lifetime = timesteps;
	growtime = 0.6 * lifetime;
	age = 0;
	dropSpeed = 0;
	return self;
}

+(id)iceWithLifetime: (int)timesteps
{
	return [[[Ice alloc] initWithLifetime: timesteps] autorelease];
}

-(void)shakeLoose
{
	age = lifetime;
}

-(BOOL)timeStep
{
	age++;
	CGPoint o = [self origin];
	if( age <= growtime ) {
		o.x = (320.0f - (320.0f * (age/(float)growtime)) )+169.0f;
		[self setOrigin: o];
	} else if( o.x < -169 ) {
		return YES;
	} else if( age > lifetime ) {
		o.x -= dropSpeed;
		dropSpeed += 1.3;
	}
	[self setOrigin: o];
	return NO;
}

@end


@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	santaSpeed -= y * 11.0;
	if( fabs(y) >= 0.3 ) {
		int count;
		for( count=0; count < [iceSpearsOfDoom count]; count++ ) {
			[[iceSpearsOfDoom objectAtIndex: count] shakeLoose];
		}
	}
}

-(void)addIce
{
	Ice *ice = [Ice iceWithLifetime: 300 - ((280 * ((MIN(100.0,lifeTimer))/100.0)))];
	[[timeView superview] insertSubview: ice below: timeView];
	[iceSpearsOfDoom addObject: ice];
}

-(void)santaDied
{
	gameRunning = NO;
	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setDelegate: self];
	[alert setTitle: @"Ho Ho... Noooo! *splat*"];
	[alert setBodyText: @"Uh oh! You've let Santa down!\nHe got hurt and now all the good little boys and girls won't get any presents this year. Bummer.\nBetter luck next time..."];
	[alert addButtonWithTitle: @"Play Again"];
	[alert popupAlertAnimated: NO];
	[alert setRotationBy: 90];
}

-(void)runLoop
{
	CGPoint o = [santa origin];
	o.y += santaSpeed;
	if( o.y < 0 ) {
		santaSpeed = 0;
		o.y = 0;
	} else if( o.y > 413 ) {
		santaSpeed = 0;
		o.y = 413;
	}

	int maxSpears;
	if( lifeTimer > 90 )
		maxSpears = 7;
	else if( lifeTimer > 60 )
		maxSpears = 6;
	else if( lifeTimer > 30 )
		maxSpears = 5;
	else
		maxSpears = 4;

	if( [iceSpearsOfDoom count] < maxSpears && r() < 0.1 )
		[self addIce];

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 3];
	[UIView setAnimationDuration:0.05];
	[santa setOrigin: o];
	NSArray *ice = [NSArray arrayWithArray: iceSpearsOfDoom];
	int count;
	CGPoint santaPoint = [santa origin];
	for( count=0; count < [ice count]; count++ ) {
		Ice *i = [ice objectAtIndex: count];
		CGPoint icePoint = [i origin];
		BOOL done = [i timeStep];
		if( done ) {
			[i removeFromSuperview];
			[iceSpearsOfDoom removeObject: i];
		} else if( icePoint.x <= -30 ) {
			// check for splat...
			float width = [[i image] size].height;
			if( (icePoint.y >= santaPoint.y && icePoint.y <= santaPoint.y+67)
			 || (icePoint.y+width >= santaPoint.y && icePoint.y+width <= santaPoint.y+67) ) {
				[self santaDied];
			}
		}
	}
	[UIView endAnimations];

	lifeTimer += 0.05;
	[timeView setText: [NSString stringWithFormat: @"%0.1f seconds",lifeTimer]];

	if( gameRunning )
		[self performSelector: @selector(runLoop) withObject: nil afterDelay: 0.05];
}

-(void)removeAllIceSpearsOfDoom
{
	int count;
	for( count=0; count < [iceSpearsOfDoom count]; count++ )
		[[iceSpearsOfDoom objectAtIndex: count] removeFromSuperview];
	[iceSpearsOfDoom removeAllObjects];
}

-(void)startGame
{
	gameRunning = YES;
	lifeTimer = 0;
	[self removeAllIceSpearsOfDoom];
	[self runLoop];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[sheet dismissAnimated: NO];
	[self startGame];
}

-(void)showCave
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"cave.jpg"]] autorelease];
	santa = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"santa.png"]];
	[bg addSubview: santa];

	timeView = [[UITextView alloc] initWithFrame: CGRectMake(203,100,200,25)];
	float alphaColor[] = { 0, 0, 0, 0 };
	[timeView setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[timeView setTextSize: 13];
	[timeView setRotationBy: 90];
	[bg addSubview: timeView];

	[window setContentView: bg];
	[self startGame];
}

-(void)showDigg
{
	[self openURL: [NSURL URLWithString: @"http://digg.com/apple/iApp_a_Day"]];
}

-(void)showMenu
{
	MenuView *menu = [[[MenuView alloc] initWithTitle: @"Sleigh" body: @"Turn your iPhone or iPod on its side and help Santa avoid the falling ice!"] autorelease];
	[menu addButtonWithTitle: @"Start The Game" target: self action: @selector(showCave)];
	[menu addButtonWithTitle: @"Digg iApp-a-Day!" target: self action: @selector(showDigg)];
	[window setContentView: menu];
	[menu showMenu];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Sleigh" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showMenu)];
	[window setContentView: s];
}

-(void)dealloc
{
	[iceSpearsOfDoom release];
	[santa release];
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	srandom( time(NULL) );

        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	iceSpearsOfDoom = [[NSMutableArray alloc] init];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
