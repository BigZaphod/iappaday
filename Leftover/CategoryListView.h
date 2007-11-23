/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <UIKit/UITextView.h>

@interface CategoryListView : UIView {
	UITable *categoryTable;
	UINavigationBar *top;
}

-(void)dealloc;
-(id)initWithFrame: (CGRect)r;
-(void)showEditMode;

@end
