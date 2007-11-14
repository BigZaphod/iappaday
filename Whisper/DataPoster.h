/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface DataPoster : UIView {
	id finishedTarget;
	SEL finishedAction;
	NSURL *url;
}

-(void)dealloc;
-(id)initWithURL: (NSURL *)sendurl inView: (UIView *)view;
-(void)finishedTransferTarget: (id)target action: (SEL)action;
-(void)sendData: (NSData *)data;

@end
