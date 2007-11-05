/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "MilesPicker.h"
#import <UIKit/UIPickerTableCell.h>
#import <UIKit/UIView-Geometry.h>
#import <WebCore/WebFontCache.h>

extern NSString *dataPath;

@implementation MilesPicker

- (int)numberOfColumnsInPickerView: (id)p
{
	return 6;
}

- (int) pickerView:(UIPickerView*)picker numberOfRowsInColumn:(int)col
{
	return 10;
}

- (id) pickerView:(UIPickerView*)picker tableCellForRow:(int)row inColumn:(int)col
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	[cell setTitle: [NSString stringWithFormat:@"%d",row]];
	return cell;
}

-(NSNumber *) miles
{
	int a = [picker selectedRowForColumn:0];
	int b = [picker selectedRowForColumn:1];
	int c = [picker selectedRowForColumn:2];
	int d = [picker selectedRowForColumn:3];
	int e = [picker selectedRowForColumn:4];
	int f = [picker selectedRowForColumn:5];
	return [NSNumber numberWithInt: [[NSString stringWithFormat:@"%d%d%d%d%d%d",a,b,c,d,e,f] intValue]];
}

-(void)pickerViewLoaded: (id)blah
{
	NSArray *a = [NSArray arrayWithContentsOfFile: dataPath];
	if( a ) {
		NSDictionary *d = [a objectAtIndex: [a count]-1];
		NSString *val = [NSString stringWithFormat:@"%d", [[d objectForKey: @"miles"] intValue]];
		int i, col = 5;
		for( i=MIN(6,[val length])-1; i>=0; i-- ) {
			[picker selectRow: (int)[val characterAtIndex:i]-48 inColumn: col animated: NO];
			col--;
		}
	}
}

@end
