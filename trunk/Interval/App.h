/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UIPickerView.h>

@interface App : UIApplication {
	UIWindow *window;
	UIPickerView *datePicker;
	UITextLabel *yearsText;
	UITextLabel *monthsText;
	UITextLabel *daysText;
	UITextLabel *hoursText;
	UITextLabel *minutesText;
	UITextLabel *secondsText;
}

-(void)dealloc;

@end
