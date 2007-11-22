/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface DataPoster : NSObject {
	id finishedTarget;
	SEL finishedAction;
	NSURL *requestURL;
}

-(void)dealloc;
+(id)postToURL: (NSURL*)url;
-(void)finishedTransferTarget: (id)target action: (SEL)action;
-(void)sendData: (NSData *)data;

@end
