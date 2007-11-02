/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	NSMutableArray *wisdoms;
	BOOL playingBall;
	BOOL upsideDown;
	id triangle;
	id label;
}

-(void)dealloc;
-(void)showEightBall;

@end
