/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	UIImage *currentImage;
	int currentIndex;
	BOOL allowMenu;
}

-(void)dealloc;
@end
