/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UIPickerView.h>
#import <UIKit/UITextView.h>

@interface LetterPickerView : UIView {
	UIPickerView *picker;
	UIView *view;
	id target;
	SEL action;
	NSMutableArray *letters;
}
-(void)dealloc;
@end


@interface App : UIApplication {
	UIWindow *window;
	LetterPickerView *letterPicker;
	UIImageView *arm1;
	UIImageView *arm2;
	UIImageView *leg1;
	UIImageView *leg2;
	UIImageView *body;
	UIImageView *head;
	UIImageView *dead;
	UITextView *words;
	NSString *goalPhrase;
	NSMutableArray *guessedLetters;
	int wrong;
}

-(void)dealloc;

@end
