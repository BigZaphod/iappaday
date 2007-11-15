/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVItem.h>

@interface App : UIApplication {
	UIWindow *window;
	AVItem *scream;
	BOOL waiting;
	AVController *c;
	int panics;
}

-(void)dealloc;

@end
