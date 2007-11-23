#import "CategoryListView.h"
#import "CategoryList.h"
#import <UIKit/UIView-Geometry.h>
#import <WebCore/WebFontCache.h>

@implementation CategoryListView
- (int)numberOfRowsInTable:(UITable*)table
{
	return [CategoryList count];
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	[cell setTitle: [CategoryList categoryNameAtIndex: row]];

	CGSize s = CGSizeMake( [column width], [table rowHeight] );
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: CGRectMake(200,0,s.width,s.height)] autorelease];
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[label setText: [NSString stringWithFormat:@"$%0.2f", [CategoryList categoryValueAtIndex: row] ]];
	[cell addSubview: label];

	return cell;
}

-(BOOL)table:(UITable*)table canDeleteRow:(int)row
{
	return YES;
}

-(void)table:(UITable*)table deleteRow:(int)row
{
	[CategoryList deleteCategoryAtIndex: row];
	[categoryTable reloadData];
}

-(void)table:(UITable*)table movedRow:(int)fromRow toRow:(int)toRow
{
	[CategoryList moveCategoryAtIndex: fromRow toIndex: toRow];
}

-(void)tableRowSelected: (id)t
{
	if( ![categoryTable isRowDeletionEnabled] ) {
		UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
		[sheet setDelegate: self];
		[sheet addTextFieldWithValue: @"$" label: @"Transaction amount"];
		[sheet addButtonWithTitle: @"Spend"];
		[sheet addButtonWithTitle: [@"Add To " stringByAppendingString: [CategoryList categoryNameAtIndex: [categoryTable selectedRow]]]];
		[sheet addButtonWithTitle: @"Cancel"];
		[sheet setTag: 1];
		[sheet popupAlertAnimated: NO];
		[[sheet keyboard] setPreferredKeyboardType: 1];
		[[sheet keyboard] showPreferredLayout];
	}
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( [sheet tag] == 0 ) {
		if( button == 1 ) {
			float amount = [[[[sheet textFieldAtIndex: 1] text] stringByTrimmingCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]  floatValue];
			NSString *name = [[sheet textFieldAtIndex: 0] text];
			[CategoryList addCategoryWithName: name initialValue: amount];
			[categoryTable reloadData];
		}
	} else {
		float amount = [[[[sheet textFieldAtIndex: 0] text] stringByTrimmingCharactersInSet: [[NSCharacterSet decimalDigitCharacterSet] invertedSet]]  floatValue];
		if( button == 1 ) {
			[CategoryList addValue: amount*-1.0f toCategoryAtIndex: [categoryTable selectedRow]];
		} else if( button == 2 ) {
			[CategoryList addValue: amount toCategoryAtIndex: [categoryTable selectedRow]];
		}
		[categoryTable reloadData];
	}
	[sheet dismissAnimated: YES];
}

-(void)showListMode
{
	[categoryTable enableRowDeletion: NO];
	[top showButtonsWithLeftTitle: nil rightTitle: @"Edit"];
}

-(void)showEditMode
{
	[categoryTable enableRowDeletion: YES];
	[top showButtonsWithLeftTitle: @"Add Category" rightTitle: @"Done"];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 0 ) {
		if( [categoryTable isRowDeletionEnabled] ) {
			[self showListMode];
		} else {
			[self showEditMode];
		}
	} else if( button == 1 ) {
		if( [categoryTable isRowDeletionEnabled] ) {
			UIAlertSheet *sheet = [[[UIAlertSheet alloc] init] autorelease];
			[sheet setDelegate: self];
			[sheet addTextFieldWithValue: nil label: @"Category name"];
			[sheet addTextFieldWithValue: @"$0.00" label: @"Initial value"];
			[sheet addButtonWithTitle: @"Add Category"];
			[sheet addButtonWithTitle: @"Cancel"];
			[sheet setTag: 0];
			[sheet popupAlertAnimated: NO];
		}
	}
}

-(void)dealloc
{
	[top release];
	[categoryTable release];
	[super dealloc];
}
-(id)initWithFrame: (CGRect)r
{
	[super initWithFrame: r];

	CGSize s = [UINavigationBar defaultSize];
	top = [[UINavigationBar alloc] initWithFrame: CGRectMake(0,0,r.size.width,s.height)];
	[top setDelegate: self];
	[self addSubview: top];

	struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:20];
	UITextLabel* label = [[[UITextLabel alloc] initWithFrame: [top bounds]] autorelease];
	[label setText: @"Leftover"];
	[label setCentersHorizontally: YES];
	[label setFont: font];
	float txtColor[] = { 1, 1, 1, 1 };
	float bgColor[] = { 0,0,0,0 };
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[label setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)];
	[top addSubview: label];

	categoryTable = [[UITable alloc] initWithFrame: CGRectMake(0,s.height,r.size.width,r.size.height-s.height)];
	[categoryTable addTableColumn: [[[UITableColumn alloc] initWithTitle:@"Name" identifier:nil width: r.size.width] autorelease]];
	[categoryTable setDataSource: self];
	[categoryTable setDelegate: self];
	[categoryTable setSeparatorStyle: 1];
	[categoryTable setAllowSelectionDuringRowDeletion:NO];
	[categoryTable setAllowsReordering:YES];
	[self addSubview: categoryTable];
	[categoryTable reloadData];

	[self showListMode];

	return self;
}
@end
