/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "PricePicker.h"
#import "MilesPicker.h"
#import "ZipPicker.h"
#import <UIKit/UIWindow.h>

@interface AddWindow : UIWindow {
	id delegate;
	MilesPicker *miles;
	PricePicker *price;
	//ZipPicker *zip;
}

-(id)init;
-(void)setDelegate: (id)d;
-(void)openWindow;

@end

@protocol AddWindowDelegates
	-(void)closedAddWindow:(AddWindow *)win;
	-(void)completedAddWindow:(AddWindow *)win withDictionary:(NSDictionary *)dict;
@end

