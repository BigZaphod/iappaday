/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	NSData *picture;
}

-(void)dealloc;
-(void)showMenu;

@end
