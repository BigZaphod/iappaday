/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "CaptureView.h"
#import <UIKit/UIView-Geometry.h>
#import <PhotoLibrary/CameraButton.h>
#import <PhotoLibrary/CameraButtonBar.h>

@implementation CaptureView

-(void)gotPictureTarget: (id)target action: (SEL)action
{
	picTarget = [target retain];
	picAction = action;
}

-(void)cancelPictureTarget: (id)target action: (SEL)action
{
	cancelTarget = [target retain];
	cancelAction = action;
}

- (void)cameraControllerReadyStateChanged:(id)fp8
{
}

- (void) snapPicture
{
	[cameraView _playShutterSound];
	[cameraView closeOpenIris];
	[cc capturePhoto];
}

NSData* rotateAndShrinkAndConvertUIImage( UIImage *picture )
{
	NSMutableData *output = [[[NSMutableData alloc] init] autorelease];
	CGImageRef imageRef = [picture imageRef];

	CGContextRef bitmap = CGBitmapContextCreate(
		NULL,
		250,
		333,
		CGImageGetBitsPerComponent(imageRef),
		4*250,
		CGImageGetColorSpace(imageRef),
		CGImageGetBitmapInfo(imageRef)
	);

	CGContextTranslateCTM( bitmap, 0, 333 );
	CGContextRotateCTM( bitmap, -90*(M_PI/180) );
	CGContextDrawImage( bitmap, CGRectMake(0,0,333,250), imageRef );
	CGImageRef ref = CGBitmapContextCreateImage( bitmap );

	CGImageRef square = CGImageCreateWithImageInRect( ref, CGRectMake(20,20,220,220) );

	CGImageDestinationRef dest = CGImageDestinationCreateWithData( (CFMutableDataRef)output, CFSTR("public.jpeg"), 1, NULL );
	CGImageDestinationAddImage(dest, square, NULL);
	CGImageDestinationFinalize(dest);

	CGContextRelease( bitmap );
	CGImageRelease( ref );
	CGImageRelease( square );

	return [NSData dataWithData: output];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 ) {
		[picTarget performSelector: picAction withObject: currentPicture afterDelay: 0];
		[self removeFromSuperview];
	} else {
		[self setContentView: cameraView];
	}
	[sheet dismissAnimated: YES];
}

-(void)cameraController:(id)sender tookPicture:(UIImage*)picture withPreview:(UIImage*)preview jpegData:(NSData*)jpegdata imageProperties:(struct __CFDictionary *)imageProps
{
	[currentPicture release];
	currentPicture = [rotateAndShrinkAndConvertUIImage(picture) retain];

	UIView *previewView = [[[UIView alloc] initWithFrame: [self bounds]] autorelease];
	float bgColor[] = { 0, 0, 0, 1 };
	[previewView setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	UIImage *img = [[[UIImage alloc] initWithData: currentPicture cache: YES] autorelease];
	UIImageView *v = [[[UIImageView alloc] initWithImage: img] autorelease];
	[v setOrigin: CGPointMake(50, 22)];
	[previewView addSubview: v];
	[self setContentView: previewView];

	UIAlertSheet *alert = [[UIAlertSheet alloc] init];
	[alert setDelegate: self];
	[alert setBodyText: @"Please don't be obscene. These images may be seen by people of all ages.  It is illegal in most countries to knowingly expose a minor to indecent content."];
	[alert setAlertSheetStyle:1];
	[alert addButtonWithTitle: @"Publish"];
	[alert setDestructiveButton: [alert addButtonWithTitle: @"Retake"]];
	[alert presentSheetInView: previewView];
}

-(void)dealloc
{
	[currentPicture release];
	[picTarget release];
	[cancelTarget release];
	[cameraView release];
	[cc release];
	[super dealloc];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 1 ) {
		[self removeFromSuperview];
		[cancelTarget performSelector: cancelAction withObject: nil afterDelay: 0];
	} else {
		[self snapPicture];
	}
}

-(id)init
{
	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	frame.origin.x = frame.origin.y = 0;
	[super initWithFrame: frame];

	cameraView = [[CameraView alloc] initWithFrame: frame];

	cc = [[CameraController sharedInstance] retain];
	[cc setDelegate:self];
	[cc startPreview];

	float h = [UINavigationBar  defaultSize].height + 10;
	UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, frame.size.height-h, [UINavigationBar  defaultSize].width, h)] autorelease];
	[bar showButtonsWithLeftTitle:@"Cancel"  rightTitle:@"Take Photo" leftBack: NO];
	[bar setBarStyle: 1];
	[bar setDelegate: self];
	[cameraView addSubview: bar];

	[self setContentView: cameraView];
	return self;
}

@end
