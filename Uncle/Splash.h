/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface Splash : UIView {
	id continueTarget;
	SEL continueSelector;
}


-(id)initWithName: (NSString*)appName andAuthor: (NSString*)byLine;
-(void)continueTarget: (id)target action: (SEL)selector;

@end
