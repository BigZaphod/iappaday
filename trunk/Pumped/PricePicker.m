/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "PricePicker.h"
#import <UIKit/UIPickerTableCell.h>
#import <WebCore/WebFontCache.h>
#import <UIKit/UIView-Geometry.h>

@implementation PricePicker

- (int)numberOfColumnsInPickerView: (id)p
{
	return 3;
}

- (int) pickerView:(UIPickerView*)picker numberOfRowsInColumn:(int)col
{
	if( col == 0 ) return 10;
	if( col == 1 ) return 100;
	return 200;
}

- (id) pickerView:(UIPickerView*)picker tableCellForRow:(int)row inColumn:(int)col
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	if( col == 0 ) {
		[cell setAlignment: 3];
		[cell setTitle: [NSString stringWithFormat:@"$%d",row]];
	} else if( col == 1 ) {
		[cell setTitle: [NSString stringWithFormat:@"%02d",99-row]];
	} else if( col == 2 ) {
		[cell setTitle: [NSString stringWithFormat:@"%0.1f",(row+1)/10.0]];
	}
	return cell;
}

-(float)pickerView:(id)p tableWidthForColumn: (int)col
{
	return (col != 2 )? 70: 155;
}

-(void)drawSelectionBarFrame: (CGRect)barRect
{
	[super drawSelectionBarFrame: barRect];

	UITextLabel *label = [[[UITextLabel alloc] initWithFrame: CGRectMake(210,barRect.origin.y+8,0,0)] autorelease];
	float alphaColor[] = { 0, 0, 0, 0 };
	struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:22];
	[label setFont: font];
	[label setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[label setText: @"gallons"];
	[label sizeToFit];
	[self addSubview: label];
}

-(NSNumber *)pricePerGallon
{
        int a = [picker selectedRowForColumn:0];
        int b = 99 - [picker selectedRowForColumn:1];
	return [NSNumber numberWithFloat: [[NSString stringWithFormat:@"%d.%02d",a,b] floatValue] ];
}

-(NSNumber *)gallons
{
	return [NSNumber numberWithFloat: ([picker selectedRowForColumn:2]+1)/10.0f ];
}

@end
