/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "AddWindow.h"
#import <UIKit/UIKit.h>
#import <UIKit/UIView-Geometry.h>

@implementation AddWindow

-(void)closeWindow
{
	[delegate closedAddWindow: self];
}

-(void)done
{
	NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:
		[price pricePerGallon],	@"price",
		[price gallons],	@"gallons",
		[miles miles],		@"miles",
		//[zip zipCode],		@"zip",
	nil];
	[delegate completedAddWindow: self withDictionary: dict ];
	[self closeWindow];
}

/*
-(void)showZipPicker
{
	[self setContentView: zip];
}
*/

-(void)showMilesPicker
{
	[self setContentView: miles];
}

-(void)showPricePicker
{
	[self setContentView: price];
}

-(void)openWindow
{
	[self orderFront: self];
	[self makeKey: self];
	[self showPricePicker];
}

-(void)setDelegate: (id)d
{
	delegate = [d retain];
}

-(void)dealloc
{
	[delegate release];
	[miles release];
	[price release];
//	[zip release];
	[super dealloc];
}

-(id)init
{
	[super initWithContentRect: [UIHardware fullScreenApplicationContentRect]];

	float bgColor[] = { 1, 1, 1, 1 };
	[self setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	price = [[PricePicker alloc] initWithFrame: [self bounds] andLabelImage: [UIImage applicationImageNamed:@"label1.png"] andLeftTitle: @"Cancel" andRightTitle: @"Enter Odometer"];
	[price backTarget: self action: @selector(closeWindow)];
	[price nextTarget: self action: @selector(showMilesPicker)];

	miles = [[MilesPicker alloc] initWithFrame: [self bounds] andLabelImage: [UIImage applicationImageNamed:@"label2.png"] andLeftTitle: @"Enter Price + Gallons" andRightTitle: @"Done"];
	[miles backTarget: self action: @selector(showPricePicker)];
	[miles nextTarget: self action: @selector(done)];
/*
	zip = [[ZipPicker alloc] initWithFrame: [self bounds] andLabelImage: [UIImage applicationImageNamed:@"label3.png"] andLeftTitle: @"Enter Odometer" andRightTitle: @"Done"];
	[zip backTarget: self action: @selector(showMilesPicker)];
	[zip nextTarget: self action: @selector(done)];
*/

	return self;
}

@end
