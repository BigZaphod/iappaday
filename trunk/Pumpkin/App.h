/*
	By: Sean Heber  <sean@spiffytech.com>
	iApp-a-Day - November, 2007
	BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

@interface App : UIApplication {
	UIWindow	*window;
	UIImageView	*img;
	float		xTilt;
	float		yTilt;
	float		zTilt;
}

-(void)dealloc;

@end
