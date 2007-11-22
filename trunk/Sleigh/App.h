/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController.h>

@interface App : UIApplication {
	UIWindow *window;
	UIImageView *santa;
	UITextView *timeView;
	float santaSpeed;
	float lifeTimer;
	NSMutableArray *iceSpearsOfDoom;
	BOOL gameRunning;
}

-(void)dealloc;

@end
