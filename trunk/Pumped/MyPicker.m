/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "MyPicker.h"
#import <UIKit/UIPickerTableCell.h>
#import <WebCore/WebFontCache.h>
#import <UIKit/UIView-Geometry.h>

@implementation MyPicker

-(void)backTarget: (id)target action: (SEL)action
{
	backTarget = target;
	backAction = action;
}

-(void)nextTarget: (id)target action: (SEL)action
{
	nextTarget = target;
	nextAction = action;
}

-(void)drawSelectionBarFrame: (CGRect)barRect
{
	UIView *bar = [[[UIView alloc] initWithFrame: barRect] autorelease];
	float bgColor[] = { 0.2, 0.2, 0.2, 1 };
	[bar setAlpha: 0.2];
	[bar setEnabled: NO];
	[bar setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[self addSubview: bar];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 1 ) {
		[backTarget performSelector: backAction withObject: nil afterDelay: 0];
	} else {
		[nextTarget performSelector: nextAction withObject: nil afterDelay: 0];
	}
}

-(void)dealloc
{
        [picker release];
        [super dealloc];
}

-(id)initWithFrame: (CGRect)frame andLabelImage: (UIImage *)labelImage andLeftTitle: (NSString *)left andRightTitle: (NSString *)right
{
	[super initWithFrame: frame];
	frame.origin.x = frame.origin.y = 0;

	UIImageView *title = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"title.png"]] autorelease];
	[self addSubview: title];

	UIImageView *info = [[[UIImageView alloc] initWithImage: labelImage] autorelease];
	[info setOrigin: CGPointMake(0,340)];
	[self addSubview: info];

	CGSize s = [UIPickerView defaultSize];
	picker = [[UIPickerView alloc] initWithFrame: CGRectMake(0,125,s.width,s.height) ];
	[picker setDelegate: self];
	[picker reloadData];
	[picker setAllowsMultipleSelection: NO];
	[self addSubview: picker];

	CGRect barRect = [picker selectionBarRect];
	barRect.origin.y += 125;
	[self drawSelectionBarFrame: barRect];

	CGSize bs = [UINavigationBar defaultSize];
	UINavigationBar *b = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,[self bounds].size.height-bs.height,bs.width,bs.height)] autorelease];
	[b showButtonsWithLeftTitle: left rightTitle: right];
	[b setDelegate: self];
	[self addSubview: b];

	return self;
}

@end
