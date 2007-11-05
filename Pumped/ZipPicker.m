/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "ZipPicker.h"
#import <UIKit/UIPickerTableCell.h>
#import <UIKit/UIView-Geometry.h>

extern NSString *dataPath;

@implementation ZipPicker

- (int)numberOfColumnsInPickerView: (id)p
{
	return 5;
}

- (int) pickerView:(UIPickerView*)picker numberOfRowsInColumn:(int)col
{
	return 11;
}

- (id) pickerView:(UIPickerView*)picker tableCellForRow:(int)row inColumn:(int)col
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	if( row > 0 )
		[cell setTitle: [NSString stringWithFormat:@"%d",row-1]];
	return cell;
}

-(NSString *)zipCode
{
	int a = [picker selectedRowForColumn:0];
	int b = [picker selectedRowForColumn:1];
	int c = [picker selectedRowForColumn:2];
	int d = [picker selectedRowForColumn:3];
	int e = [picker selectedRowForColumn:4];
	if( a && b && c && d && e )
		return [NSString stringWithFormat:@"%d%d%d%d%d", a-1, b-1, c-1, d-1, e-1];
	return nil;
}

-(void)pickerViewLoaded: (id)blah
{
	NSArray *a = [NSArray arrayWithContentsOfFile: dataPath];
	if( a ) {
		NSDictionary *d = [a objectAtIndex: [a count]-1];
		NSString *val = [d objectForKey: @"zip"];
		if( val ) {
	                int i;
			for( i=0; i<5; i++ ) {
				[picker selectRow: 1+((int)[val characterAtIndex:i]-48) inColumn: i animated: NO];
			}
		}
	}
}


@end
