/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "GameView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UIView-Gestures.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController.h>

static const float friction = 0.985;
static const float puckRadius = 9;
static const float paddleRadius = 28;
static const float paddleMass = 10;
static const float puckMass = 4;

extern CGPoint GSEventGetInnerMostPathPosition(struct __GSEvent*);
extern CGPoint GSEventGetOuterMostPathPosition(struct __GSEvent*);

@implementation GameView

- (void)gestureStarted:(struct __GSEvent *)event
{
        [self gestureChanged: event];
	[fingerMessage removeFromSuperview];
	gameInProgress = YES;
}

-(void)showFingerMessage
{
	gameInProgress = NO;
	[self addSubview: fingerMessage];
}

- (void)gestureEnded:(struct __GSEvent *)event
{
	if( gameInProgress )
		[self showFingerMessage];
}

float distanceBetweenPoints( CGPoint p1, CGPoint p2 )
{
	float x = p2.x - p1.x;
	float y = p2.y - p1.y;
	return sqrtf( (x*x)+(y*y) );
}

- (void)gestureChanged:(struct __GSEvent *)event {
        CGPoint left = GSEventGetInnerMostPathPosition(event);
        CGPoint right = GSEventGetOuterMostPathPosition(event);
	CGPoint p2new;
	CGPoint p1new;

	if( right.y < 240 ) {
		p1new = right;
		p2new = left;
	} else {
		p1new = left;
		p2new = right;
	}

	if( p1new.x < 0 ) p1new.x = 0;
	if( p1new.x > [self bounds].size.width-(2*paddleRadius) ) p1new.x = [self bounds].size.width-(2*paddleRadius);
	if( p2new.x < 0 ) p2new.x = 0;
	if( p2new.x > [self bounds].size.width-(2*paddleRadius) ) p2new.x = [self bounds].size.width-(2*paddleRadius);

	if( p1new.y < 0 ) p1new.y = 0;
	if( p1new.y > [self bounds].size.height-(2*paddleRadius) ) p1new.y = [self bounds].size.height-(2*paddleRadius);
	if( p2new.y < 0 ) p2new.y = 0;
	if( p2new.y > [self bounds].size.height-(2*paddleRadius) ) p2new.y = [self bounds].size.height-(2*paddleRadius);

	CGPoint p1from = [player1 origin];
	CGPoint p2from = [player2 origin];

	player1Speed.x = p1new.x - p1from.x;
	player1Speed.y = p1new.y - p1from.y;

	player2Speed.x = p2new.x - p2from.x;
	player2Speed.y = p2new.y - p2from.y;

	[player1 setOrigin: p1new];
	[player2 setOrigin: p2new];
}

-(void)calculateCollisionWithWallOf: (CGPoint*)position withRadiusOf: (float)r movingAtSpeed: (CGPoint*)speed
{
	if( position->x > [self bounds].size.width - r ) {
		position->x = [self bounds].size.width - r;
		speed->x *= -0.99;
	}
	if( position->x < r ) {
		position->x = r;
		speed->x *= -0.99;
	}
	if( position->y > [self bounds].size.height - r ) {
		position->y = [self bounds].size.height - r;
		speed->y *= -0.99;
	}
	if( position->y < r ) {
		position->y = r;
		speed->y *= -0.99;
	}
}

-(void)calculateCollisionOfPlayer: (CGPoint*)paddlePosition movingAtSpeed: (CGPoint*)speed usingPuckPosition: (CGPoint*)puckPosition
{
	paddlePosition->x += speed->x;
	paddlePosition->y += speed->y;

	float collisionDistance = puckRadius + paddleRadius;
	float actualDistance = distanceBetweenPoints( *puckPosition, *paddlePosition );

	if( actualDistance < collisionDistance ) {
		float collNormalAngle = atan2f( paddlePosition->y-puckPosition->y, paddlePosition->x-puckPosition->x);

		// now move the objects to where they just touch (eliminate any overlap)
		float moveDist1 = (collisionDistance-actualDistance) * (paddleMass/((puckMass + paddleMass)));
		float moveDist2 = (collisionDistance-actualDistance) * (puckMass/((puckMass + paddleMass)));

		puckPosition->x += moveDist1 * cosf( collNormalAngle+180 );
		puckPosition->y += moveDist1 * sinf( collNormalAngle+180 );

		paddlePosition->x += moveDist2 * cosf( collNormalAngle );
		paddlePosition->y += moveDist2 * sinf( collNormalAngle );

		// objects are now repositioned... the next step is to change the motion vectors as needed
		CGPoint normalVector;
		normalVector.x = cosf( collNormalAngle );
		normalVector.y = sinf( collNormalAngle );

		float a1 = (puckSpeed.x * normalVector.x) + (puckSpeed.y * normalVector.y);
		float a2 = (speed->x * normalVector.x) + (speed->y * normalVector.y);
		float optimisedP = (2.0 * (a1-a2)) / (puckMass + paddleMass);

		// now chart the resulting vectors
		puckSpeed.x -= (optimisedP * paddleMass * normalVector.x);
		puckSpeed.y -= (optimisedP * paddleMass * normalVector.y);

		speed->x += (optimisedP * puckMass * normalVector.x);
		speed->y += (optimisedP * puckMass * normalVector.y);
	}
}

-(void)resetScores
{
	player1Score = player2Score = 0;
}

-(void)resetGameState
{
	CGSize s = [self bounds].size;
	[puck setOrigin: CGPointMake(s.width/2.0 - puckRadius, s.height/2.0-puckRadius)];
	[player1 setOrigin: CGPointMake( s.width/2.0-paddleRadius, (s.height/3.0) - (2*paddleRadius))];
	[player2 setOrigin: CGPointMake( s.width/2.0-paddleRadius, s.height - (s.height/3.0))];
	puckSpeed = player1Speed = player2Speed = CGPointMake(0,0);
}

-(void)showScore
{
	gameInProgress = NO;
	UIAlertSheet *alert = [[[UIAlertSheet alloc] init] autorelease];
	[alert setDimsBackground: YES];
	[alert setDelegate: self];
	[alert setTitle: @"SCORE!"];
	[alert setBodyText: [NSString stringWithFormat: @"Blue Player: %d\nGreen Player: %d",player1Score, player2Score]];
	[alert addButtonWithTitle: @"Reset Scores"];
	[alert addButtonWithTitle: @"Continue Playing"];
	[alert popupAlertAnimated: YES];
	[self resetGameState];
}

-(void)gameLoop
{
	[UIView beginAnimations:nil];
	[UIView setAnimationCurve: 3];
	[UIView setAnimationDuration:0.02];

	// apply movement to puck
	CGPoint puckPosition = [puck origin];
	puckPosition.x += puckSpeed.x;
	puckPosition.y += puckSpeed.y;

	// center the vector
	puckPosition.x += puckRadius;
	puckPosition.y += puckRadius;

	// adjust for friction (very low)
	puckSpeed.x *= friction;
	puckSpeed.y *= friction;
	player1Speed.x *= friction;
	player1Speed.y *= friction;
	player2Speed.x *= friction;
	player2Speed.y *= friction;

	CGPoint player1Position = [player1 origin];
	player1Position.x += paddleRadius;
	player1Position.y += paddleRadius;

	CGPoint player2Position = [player2 origin];
	player2Position.x += paddleRadius;
	player2Position.y += paddleRadius;

	// check for wall hits and bounce with extra friction
	[self calculateCollisionWithWallOf: &puckPosition withRadiusOf: puckRadius movingAtSpeed: &puckSpeed];
	[self calculateCollisionWithWallOf: &player1Position withRadiusOf: paddleRadius movingAtSpeed: &player1Speed];
	[self calculateCollisionWithWallOf: &player2Position withRadiusOf: paddleRadius movingAtSpeed: &player2Speed];

	// compute paddle hits...
	[self calculateCollisionOfPlayer: &player1Position movingAtSpeed: &player1Speed usingPuckPosition: &puckPosition];
	[self calculateCollisionOfPlayer: &player2Position movingAtSpeed: &player2Speed usingPuckPosition: &puckPosition];

	// actually move the objects
	[player1 setOrigin: CGPointMake(player1Position.x-paddleRadius, player1Position.y-paddleRadius)];
	[player2 setOrigin: CGPointMake(player2Position.x-paddleRadius, player2Position.y-paddleRadius)];
	[puck setOrigin: CGPointMake(puckPosition.x-puckRadius, puckPosition.y-puckRadius)];

	// check for score
	if( gameInProgress ) {
		if( puckPosition.x >= 99 && puckPosition.x <= 219 ) {
			if( puckPosition.y <= 10 ) {
				player2Score++;
				[self showScore];
			} else if( puckPosition.y >= 470 ) {
				player1Score++;
				[self showScore];
			}
		}
	}

	[UIView endAnimations];
	[self performSelector: @selector(gameLoop) withObject: nil afterDelay: 0.02];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 ) [self resetScores];
	gameInProgress = YES;
	[sheet dismissAnimated: YES];
}

-(void)dealloc
{
	[fingerMessage release];
	[player1 release];
	[player2 release];
	[super dealloc];
}

-(id)init
{
	[super initWithImage: [UIImage applicationImageNamed:@"Default.png"]];

	fingerMessage = [[UITextView alloc] initWithFrame: CGRectMake(20,146,280,186)];
	[fingerMessage setText: @"Place the device on a flat table. Both players must have their fingers on the screen at the same time in order to play."];
	[fingerMessage setEditable: NO];
	[fingerMessage setEnabled: NO];
	float bgColor[] = { 0.5, 0.5, 0.5, 0.4 };
	[fingerMessage setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	puck = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"puck.png"]];
	player1 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"blue.png"]];
	player2 = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"green.png"]];

	[self addSubview: puck];
	[self addSubview: player1];
	[self addSubview: player2];

	[self setEnabledGestures: YES];
	[self setGestureDelegate: self];

	[self resetScores];
	[self resetGameState];
	[self gameLoop];

	[self showFingerMessage];
	return self;
}

@end
