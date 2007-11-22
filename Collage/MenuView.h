/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>

@interface MenuView : UIView {
	NSMutableArray *targets;
	UIAlertSheet *alert;
}

-(void)dealloc;
-(id)init;
-(id)initWithTitle: (NSString *)title body: (NSString *)body;
-(void)addButtonWithTitle: (NSString *)title target: (id)target action: (SEL)selector;
-(void)showMenu;

@end
