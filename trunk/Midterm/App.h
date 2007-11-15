/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <Celestial/AVController.h>
#import <Celestial/AVRecorder.h>
#import <Celestial/AVItem.h>

@interface App : UIApplication {
	UIWindow *window;
	int whisperCounter;
	int questCounter;
	int graffitiCounter;
	AVController *ac;
	UIImageView *questImage;
	UITextLabel *graffitiText;
}

-(void)dealloc;

@end
