/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

@interface BallView : UIImageView {
	float radius;
	float mass;
	float friction;
	CGPoint speedVector;
	CGPoint where;
	BOOL hit;
	Tone *tone;
	NSMutableArray *bumped;
}
@end

@implementation BallView
-(void)dealloc
{
	[bumped release];
	[tone release];
	[super dealloc];
}
-(id)initWithFile: (NSString*)str
{
	[super initWithImage: [UIImage applicationImageNamed: str]];
	radius = [[self image] size].width / 2.0;
	mass = radius;
	friction = 0.99;
	bumped = [[NSMutableArray alloc] init];
	tone = [[Tone toneWithFrequency: 90 + (12 * radius) attack: 0.08 decay: 0.05 sustain: 0.75 release: 0.08 lifespan: 0.09 ] retain];
	return self;
}
-(void)addAcceleration: (CGPoint)a
{
	speedVector.x += a.x;
	speedVector.y += a.y;
}
-(void)applyFriction
{
	speedVector.x *= friction;
	speedVector.y *= friction;
}
-(void)beginMotion
{
	[bumped removeAllObjects];
	where = [self origin];
	where.x += radius;
	where.y += radius;
	where.x += speedVector.x;
	where.y += speedVector.y;
}
-(void)bounceWithinBox: (CGSize)box
{
	if( where.x > box.width - radius ) {
		hit = YES;
		where.x = box.width - radius;
		speedVector.x *= -0.99;
	}
	if( where.x < radius ) {
		hit = YES;
		where.x = radius;
		speedVector.x *= -0.99;
	}
	if( where.y > box.height - radius ) {
		hit = YES;
		where.y = box.height - radius;
		speedVector.y *= -0.99;
	}
	if( where.y < radius ) {
		hit = YES;
		where.y = radius;
		speedVector.y *= -0.99;
	}
}

float distanceBetweenPoints( CGPoint p1, CGPoint p2 )
{
        float x = p2.x - p1.x;
        float y = p2.y - p1.y;
        return sqrtf( (x*x)+(y*y) );
}

-(void)collideWithBalls: (NSArray*)balls
{
	int i;
	for( i=0; i<[balls count]; i++ ) {
		BallView *ball = [balls objectAtIndex: i];
		if( ball == self || [bumped containsObject: ball]) continue;

	        float collisionDistance = radius + ball->radius;
	        float actualDistance = distanceBetweenPoints( where, ball->where );

	        if( actualDistance < collisionDistance ) {
			hit = YES;
			[bumped addObject: ball];
			[ball->bumped addObject: self];

	                float collNormalAngle = atan2f( where.y - ball->where.y, where.x - ball->where.x);

	                // now move the objects to where they just touch (eliminate any overlap)
	                float moveDist1 = (collisionDistance-actualDistance) * (mass/((ball->mass + mass)));
	                float moveDist2 = (collisionDistance-actualDistance) * (ball->mass/((ball->mass + mass)));

	                ball->where.x += moveDist1 * cosf( collNormalAngle+180 );
	                ball->where.y += moveDist1 * sinf( collNormalAngle+180 );

	                where.x += moveDist2 * cosf( collNormalAngle );
	                where.y += moveDist2 * sinf( collNormalAngle );

	                // objects are now repositioned... the next step is to change the motion vectors as needed
	                CGPoint normalVector;
	                normalVector.x = cosf( collNormalAngle );
	                normalVector.y = sinf( collNormalAngle );

	                float a1 = (ball->speedVector.x * normalVector.x) + (ball->speedVector.y * normalVector.y);
	                float a2 = (speedVector.x * normalVector.x) + (speedVector.y * normalVector.y);
	                float optimisedP = (2.0 * (a1-a2)) / (ball->mass + mass);

	                // now chart the resulting vectors
        	        ball->speedVector.x -= (optimisedP * mass * normalVector.x);
	                ball->speedVector.y -= (optimisedP * mass * normalVector.y);

	                speedVector.x += (optimisedP * ball->mass * normalVector.x);
	                speedVector.y += (optimisedP * ball->mass * normalVector.y);
        	}
	}
}
-(void)endMotion
{
	where.x -= radius;
	where.y -= radius;
	[self setOrigin: where];
}

-(void)playToneWithPlayer: (TonePlayer*)player
{
	if( hit && ![player playingTone: tone] )
		[player addTone: tone];
	hit = NO;
}
@end

@implementation App

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	int i;
	for( i=0; i<[balls count]; i++ ) {
		BallView *ball = [balls objectAtIndex: i];
		[ball addAcceleration: CGPointMake(-3.5*x,-3.5*y)];
	}
}

-(void)gameLoop
{
	int i;
	for( i=0; i<[balls count]; i++ ) {
		BallView *ball = [balls objectAtIndex: i];
		[ball applyFriction];
		[ball beginMotion];
		[ball bounceWithinBox: [window bounds].size];
	}

	for( i=0; i<[balls count]; i++ ) {
		BallView *ball = [balls objectAtIndex: i];
		[ball collideWithBalls: balls];
	}

	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 3];
	[UIView setAnimationDuration:0.02];

	for( i=0; i<[balls count]; i++ ) {
		[[balls objectAtIndex: i] endMotion];
	}

	[UIView endAnimations];
	[self performSelector: @selector(gameLoop) withObject: nil afterDelay: 0.02];
}

-(void)toneLoop
{
	int i;
	for( i=0; i<[balls count]; i++ )
		[[balls objectAtIndex: i] playToneWithPlayer: player];
	[self performSelector: @selector(toneLoop) withObject: nil afterDelay: 0.08];
}

-(void)startGame
{
	UIImageView *bg = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];

	#define BALL(x) { \
		id b = [[[BallView alloc] initWithFile: @x".png"] autorelease]; \
		[balls addObject: b]; \
		[bg addSubview: b]; \
	}

	BALL("red")
	BALL("yellow")
	BALL("blue")
	BALL("green")
	BALL("purple")
	BALL("grey")
	BALL("orange")

	[window setContentView: bg];
	[player play];

	[self gameLoop];
	[self toneLoop];
}

-(void)showSplash
{
	SplashView *s = [[SplashView alloc] initWithName: @"Bonk" andAuthor:@"Sean Heber <sean@spiffytech.com>" andArtist: nil];
	[s continueTarget: self action: @selector(startGame)];
	[window setContentView: s];
}

-(void)dealloc
{
	[player release];
	[window release];
	[balls release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
        [UIHardware _setStatusBarHeight:0.0f];
        [self setStatusBarMode:2 orientation:0 duration:0.0f fenceID:0];

	player = [[TonePlayer alloc] init];
	balls = [[NSMutableArray alloc] init];
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
