/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVItem.h>
#import <MusicLibrary/MusicLibrary.h>
#import <MusicLibrary/MLQuery.h>

@interface App : UIApplication {
	UIWindow *window;
	BOOL vibrating;
	BOOL playing;
	AVController *c;
	AVItem *gobble;
	UIImageView *turkey;
	UIImageView *mouth;
	CGPoint turkeySpeed;
	BOOL canJump;
	BOOL canChangeTune;
	BOOL mouthClosed;
	BOOL playingMusic;
	MusicLibrary *ml;
	MLQuery *q;
	int terribleHackCuzImLazyAndTired;
}

-(void)dealloc;

@end
