/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

extern NSString *kUIButtonBarButtonAction;
extern NSString *kUIButtonBarButtonInfo;
extern NSString *kUIButtonBarButtonInfoOffset;
extern NSString *kUIButtonBarButtonSelectedInfo;
extern NSString *kUIButtonBarButtonStyle;
extern NSString *kUIButtonBarButtonTag;
extern NSString *kUIButtonBarButtonTarget;
extern NSString *kUIButtonBarButtonTitle;
extern NSString *kUIButtonBarButtonTitleVerticalHeight;
extern NSString *kUIButtonBarButtonTitleWidth;
extern NSString *kUIButtonBarButtonType;

typedef struct {
	float r;
	float g;
	float b;
} rgb;

static rgb COLORS[6] = {
	{0,0,0},
	{1,0,0},
	{0,1,0},
	{0,0,1},
	{0,0,1},
	{1,0.65,0}
};

@implementation App

-(void)updateDrawing
{
	CGImageRef r = CGBitmapContextCreateImage(context);
	UIImage *img = [[[UIImage alloc] initWithImageRef: r] autorelease];
	[imgView setImage: img];
	CGImageRelease( r );
}

- (void)acceleratedInX:(float)x Y:(float)y Z:(float)z
{
	if( !context || !drawing ) return;

	penY += y * 30.0f;
	penX += x * 30.0f;

	float maxY = CGBitmapContextGetHeight(context) - 4;
	float maxX = CGBitmapContextGetWidth(context) - 4;

	if( penY <= 0 ) penY = 0;
	if( penY > maxY ) penY = maxY;

	if( penX >= 0 ) penX = 0;
	if( penX < -maxX ) penX = -maxX;

	CGContextFillRect( context, CGRectMake(-penX, penY, 4, 4) );

	[self updateDrawing];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 )
		CGContextClearRect( context, CGRectMake(0,0,CGBitmapContextGetWidth(context),CGBitmapContextGetHeight(context)) );
	[sheet dismissAnimated: YES];
	drawing = YES;
}

-(void)clearDrawing
{
        UIAlertSheet *alert = [[UIAlertSheet alloc] init];
        [alert setDelegate: self];
	[alert setAlertSheetStyle: 2];
        [alert setTitle: @"Erase Drawing?"];
	[alert setDestructiveButton: [alert addButtonWithTitle: @"Yes"]];
        [alert addButtonWithTitle: @"No"];
        [alert popupAlertAnimated: YES];
	drawing = NO;
}

-(void)cycleColor
{
	currentColor++;
	if( currentColor == 6 ) currentColor = 0;
	CGContextSetRGBFillColor( context, COLORS[currentColor].r, COLORS[currentColor].g, COLORS[currentColor].b, 1 );
	CGContextFillRect( context, CGRectMake(-penX, penY, 4, 4) );
}

-(void)shareDrawing
{
	NSMutableData *output = [[NSMutableData alloc] init];
	CGImageRef ref = [[window contentView] createSnapshotWithRect: CGRectMake(0,0,CGBitmapContextGetWidth(context),CGBitmapContextGetHeight(context))];
	CGImageDestinationRef dest = CGImageDestinationCreateWithData( (CFMutableDataRef)output, CFSTR("public.jpeg"), 1, NULL );
	CGImageDestinationAddImage(dest, ref, NULL);
	CGImageDestinationFinalize(dest);
	[output writeToFile: @"/tmp/scribble.jpg" atomically: YES];
	CGImageRelease( ref );
	CFRelease( dest );
	[output release];
	[self openURL: [NSURL URLWithString: @"mailto:?attachment=/tmp/scribble.jpg"]];
}

-(void)showCanvas
{
	UIImageView *canvas = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	[canvas addSubview: imgView];

	NSDictionary *buttonClear = [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget,
		@"clearDrawing", kUIButtonBarButtonAction,
		[NSNumber numberWithUnsignedInt:1], kUIButtonBarButtonTag,
		[NSNumber numberWithUnsignedInt:3], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:1], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:75], kUIButtonBarButtonTitleWidth,
		@"Clear", kUIButtonBarButtonInfo,
		nil
	];
	NSDictionary *buttonColor = [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget,
		@"cycleColor", kUIButtonBarButtonAction,
		[NSNumber numberWithUnsignedInt:2], kUIButtonBarButtonTag,
		[NSNumber numberWithUnsignedInt:3], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:1], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:76], kUIButtonBarButtonTitleWidth,
		@"Change Color", kUIButtonBarButtonInfo,
		nil
	];
	NSDictionary *buttonShare = [NSDictionary dictionaryWithObjectsAndKeys:
		self, kUIButtonBarButtonTarget,
		@"shareDrawing", kUIButtonBarButtonAction,
		[NSNumber numberWithUnsignedInt:3], kUIButtonBarButtonTag,
		[NSNumber numberWithUnsignedInt:3], kUIButtonBarButtonStyle,
		[NSNumber numberWithUnsignedInt:1], kUIButtonBarButtonType,
		[NSNumber numberWithUnsignedInt:75], kUIButtonBarButtonTitleWidth,
		@"Email Drawing", kUIButtonBarButtonInfo,
		nil
	];
	NSArray *items = [NSArray arrayWithObjects:buttonClear, buttonColor, buttonShare, nil];

	float height = [UIButtonBar defaultHeight];
	UIButtonBar *bar = [[[UIButtonBar alloc] initInView: canvas withItemList: items] autorelease];
	[bar setOrigin: CGPointMake(0,[window bounds].size.height-height)];
	int buttons[3] = { 1, 2, 3 };
	[bar showButtons: buttons withCount: 3 withDuration: 0];

	context = CGBitmapContextCreate( NULL, [window bounds].size.width, [window bounds].size.height-height, 8, 320*4, CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB), kCGImageAlphaPremultipliedLast );
	currentColor = -1;
	[self cycleColor];

	[window setContentView: canvas];
	drawing = YES;
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Scribble" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showCanvas)];
	[window setContentView: s];
}

-(void)dealloc
{
	[imgView release];
	CGContextRelease( context );
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];

	[window orderFront: self];
	[window makeKey: self];

	imgView = [[UIImageView alloc] init];
	context = NULL;
	penX = penY = 0;

	[self showSplash];
}

@end
