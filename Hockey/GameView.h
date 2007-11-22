/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

@interface GameView : UIImageView {
	UIImageView *player1;
	UIImageView *player2;
	UIImageView *puck;

	CGPoint puckSpeed;
	CGPoint player1Speed;
	CGPoint player2Speed;

	int player1Score;
	int player2Score;

	BOOL gameInProgress;
	UITextView *fingerMessage;
}

-(void)dealloc;
-(id)init;

@end
