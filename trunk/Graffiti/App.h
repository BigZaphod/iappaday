/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface MyImageView : UIImageView {
        id target;
}
-(void)dealloc;
-(void)messageEnterDelegate: (id)t;
@end

@interface App : UIApplication {
	UIWindow *window;
	float currentRotation;
	CGPoint currentPoint;
	BOOL trackRotation;
	MyImageView *wall;
	int currentIndex;
	NSMutableArray *graffiti;
}

-(void)dealloc;
-(void)enterMessageAtPoint: (CGPoint)p;

@end
