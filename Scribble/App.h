/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface App : UIApplication {
	UIWindow *window;
	CGContextRef context;
	UIImageView *imgView;
	float penX;
	float penY;
	int currentColor;
	BOOL drawing;
}

-(void)dealloc;

@end
