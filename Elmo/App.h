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
	BOOL vibrating;
	BOOL playing;
	AVController *c;
	AVItem *laugh;
}

-(void)dealloc;

@end
