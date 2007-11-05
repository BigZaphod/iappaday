/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UIPickerView.h>

@interface MyPicker : UIView {
	UIPickerView *picker;
	id backTarget;
	SEL backAction;
	id nextTarget;
	SEL nextAction;
}

-(void)dealloc;
-(id)initWithFrame: (CGRect)frame andLabelImage: (UIImage *)labelImage andLeftTitle: (NSString *)left andRightTitle: (NSString *)right;
-(void)drawSelectionBarFrame: (CGRect)barRect;
-(void)backTarget: (id)target action: (SEL)action;
-(void)nextTarget: (id)target action: (SEL)action;

@end
