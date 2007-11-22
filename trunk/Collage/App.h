/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UITiledView.h>

@interface SpaceView : UITiledView {}
@end

@interface App : UIApplication {
	UIWindow *window;
	float currentRotation;
	CGPoint currentPoint;
	BOOL trackRotation;

	SpaceView *space;

	int currentIndex;

	NSMutableArray *items;
}

-(void)dealloc;
-(void)tappedAtPoint: (CGPoint)p;

@end
