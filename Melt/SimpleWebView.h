/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UIScroller.h>
#import <UIKit/UIWebView.h>

@interface SimpleWebView : UIView {
	UIWebView *webView;
	UIScroller *scroller;
	id menuTarget;
	SEL menuAction;
	NSURLRequest *urlRequest;
}

-(id)initWithFrame: (CGRect)frame andURL: (NSURL *)url andReloadURL: (NSURL *)reload;
-(void)dealloc;
-(void)menuTarget: (id)target action: (SEL)action;

@end
