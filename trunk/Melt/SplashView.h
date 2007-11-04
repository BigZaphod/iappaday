#import <UIKit/UIKit.h>

@interface SplashView : UIView {
	id continueTarget;
	SEL continueSelector;
}


-(id)initWithName: (NSString*)appName andAuthor: (NSString*)byLine;
-(void)continueTarget: (id)target action: (SEL)selector;

@end
