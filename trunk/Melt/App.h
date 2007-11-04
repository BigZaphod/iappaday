/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	UIImageView *ice;
	UIImageView *shadow;
	UITextLabel *label;
	float progress;
	float seconds;
}

-(void)dealloc;

@end
