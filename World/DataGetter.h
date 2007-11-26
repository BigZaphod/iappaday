/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface DataGetter : NSObject {
	id finishedTarget;
	SEL finishedAction;
	NSURL *requestURL;
}

-(void)dealloc;
-(void)performRequest;
-(void)finishedTransferTarget: (id)target action: (SEL)action;
+(id)dataWithURL: (NSURL*)url;

@end
