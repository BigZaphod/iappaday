/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface DataGetter : NSObject {
	id finishedTarget;
	SEL finishedAction;
}

-(void)dealloc;
-(void)finishedTransferTarget: (id)target action: (SEL)action;
+(id)dataWithURL: (NSURL*)url;

@end
