/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

#define numPoints 27

@interface App : UIApplication {
	UIWindow *window;
	CGPoint points[numPoints];
	NSMutableArray *leaves;
}

-(void)dealloc;

@end
