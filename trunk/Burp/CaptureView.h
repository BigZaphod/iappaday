/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <PhotoLibrary/CameraController.h>
#import <PhotoLibrary/CameraView.h>

@interface NSObject (CaptureViewDelegateMethods)
- (void)pictureData: (NSData*)data;
@end

@interface CaptureView : UIView {
	CameraView *cameraView;
	CameraController *cc;
	id picTarget;
	SEL picAction;
	id menuTarget;
	SEL menuAction;
}

-(void)dealloc;
-(id)init;
-(void)pictureDataTarget: (id)target action: (SEL)action;
-(void)menuTarget: (id)target action: (SEL)action;

@end
