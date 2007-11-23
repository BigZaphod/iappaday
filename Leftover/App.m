/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import "CategoryList.h"
#import "CategoryListView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

@implementation App
-(void)showCategories
{
	CategoryListView *v = [[[CategoryListView alloc] initWithFrame: [window bounds]] autorelease];
	[window setContentView: v];

	if( [CategoryList count] == 0 ) {
		UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
		[sheet setTitle: @"Welcome to Leftover!"];
		[sheet setBodyText: @"Leftover is a simple budgeting tool. First add categories such as Grocery or Entertainment or Gas, etc. Then set the initial amount for that budget category. As you spend money, simply tap on the category and enter the amount you spent. Leftover will always show you exactly how much you have left in each category so you don't accidentally overspend!"];
		[sheet popupAlertAnimated: YES];
		[v showEditMode];
	}
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Leftover" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showCategories)];
	[window setContentView: s];
}

-(void)dealloc
{
	[window release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
