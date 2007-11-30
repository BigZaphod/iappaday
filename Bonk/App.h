/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import "TonePlayer.h"

@interface App : UIApplication {
	UIWindow *window;
	NSMutableArray *balls;
	TonePlayer *player;
}

-(void)dealloc;

@end
