/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	UIImageView *target;
	UIImageView *currentPhoto;
	BOOL hidingPhotos;
	int currentIndex;
	CGPoint tapped;
}

-(void)dealloc;

@end
