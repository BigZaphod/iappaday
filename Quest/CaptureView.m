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

-(void)pictureDataTarget: (id)target action: (SEL)action
{
	picTarget = target;
	picAction = action;
}

-(void)menuTarget: (id)target action: (SEL)action
{
	menuTarget = target;
	menuAction = action;
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
	void *data = malloc( 4*250*333 );

	CGContextRef bitmap = CGBitmapContextCreate(
		data,
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

	CGImageDestinationRef dest = CGImageDestinationCreateWithData( (CFMutableDataRef)output, CFSTR("public.jpeg"), 1, NULL );
	CGImageDestinationAddImage(dest, ref, NULL);
	CGImageDestinationFinalize(dest);

	CGContextRelease( bitmap );
	CGImageRelease( ref );
	free(data);

	return [NSData dataWithData: output];
}

-(void)cameraController:(id)sender tookPicture:(UIImage*)picture withPreview:(UIImage*)preview jpegData:(NSData*)jpegdata imageProperties:(struct __CFDictionary *)imageProps
{
	NSData *output = rotateAndShrinkAndConvertUIImage(picture);
	[picTarget performSelector: picAction withObject: output afterDelay: 0];
}

-(void)dealloc
{
	[cameraView release];
	[cc release];
	[super dealloc];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 1 ) {
		[menuTarget performSelector: menuAction withObject: nil afterDelay: 0];
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
	[self addSubview: cameraView];

	cc = [[CameraController sharedInstance] retain];
	[cc setDelegate:self];
	[cc startPreview];

	float h = [UINavigationBar  defaultSize].height;
	UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0, frame.size.height-h, [UINavigationBar  defaultSize].width, h)] autorelease];
	[bar showButtonsWithLeftTitle:@"Menu"  rightTitle:@"Take Photo" leftBack: NO];
	[bar setBarStyle: 1];
	[bar setDelegate: self];
	[self addSubview: bar];

	return self;
}

@end
