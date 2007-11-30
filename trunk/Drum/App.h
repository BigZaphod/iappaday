/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import "TonePlayer.h"

@interface App : UIApplication {
	UIWindow *window;
	TonePlayer *player;
	Tone *tone;
	BOOL beat;
	float beatAt;
}

-(void)dealloc;

@end
