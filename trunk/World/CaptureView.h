/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <PhotoLibrary/CameraController.h>
#import <PhotoLibrary/CameraView.h>

@interface CaptureView : UIWindow {
	CameraView *cameraView;
	CameraController *cc;
	id picTarget;
	SEL picAction;
	id cancelTarget;
	SEL cancelAction;
	NSData *currentPicture;
}

-(void)dealloc;
-(id)init;
-(void)gotPictureTarget: (id)target action: (SEL)action;
-(void)cancelPictureTarget: (id)target action: (SEL)action;

@end
