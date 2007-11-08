/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "Splash.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>
#import <UIKit/UITextLabel.h>
#import <WebCore/WebFontCache.h>

@implementation Splash

-(void)mouseDown: (struct __CGEvent *)e
{
	if( continueTarget )
		[continueTarget performSelector: continueSelector withObject: nil afterDelay: 0];
}

-(void)continueTarget: (id)target action: (SEL)action
{
	continueTarget = target;
	continueSelector = action;
}

-(id)initWithName: (NSString*)appName andAuthor: (NSString*)byLine
{
	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	frame.origin.x = frame.origin.y = 0;
	[super initWithFrame: frame];
	UIImageView *def = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]];
	[self addSubview: def];

	UIView *v = [[UIView alloc] initWithFrame: frame];
	[v setAlpha: 0.6];
	float bgColor[] = { 0, 0, 0, 1 };
	[v setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[self addSubview: v];

	float alphaColor[] = { 0, 0, 0, 0 };
	float shadowColor[] = { 0, 0, 0, 0.5 };
	float whiteColor[] = { 1, 1, 1, 1 };
	float byColor[] = { 0.5, 0.5, 0.5, 1 };

        struct __GSFont *font = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:36];
        UITextLabel *txt = [[UITextLabel alloc] initWithFrame: CGRectMake(0,-1000,frame.size.width,100)];
        [txt setCentersHorizontally: YES];
        [txt setFont: font];
	[txt setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[txt setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), whiteColor)];
	[txt setShadowColor:  CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor)];
	[txt setShadowOffset: CGSizeMake(3,3)];
        [txt setText: @"iApp-a-Day!"];
	[self addSubview: txt];

        struct __GSFont *font2 = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:2 size:22];
        UITextLabel *app = [[UITextLabel alloc] initWithFrame: CGRectMake(1000,226,frame.size.width,100)];
        [app setCentersHorizontally: YES];
        [app setFont: font2];
	[app setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[app setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), whiteColor)];
	[app setShadowColor:  CGColorCreate(CGColorSpaceCreateDeviceRGB(), shadowColor)];
	[app setShadowOffset: CGSizeMake(3,3)];
        [app setText: appName];
	[self addSubview: app];

	UIImageView *ico = [[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"icon.png"]];
	[ico setOrigin: CGPointMake(-1000,200)];
	[self addSubview: ico];

        struct __GSFont *font3 = [NSClassFromString(@"WebFontCache") createFontWithFamily:@"Helvetica" traits:0 size:14];
        UITextLabel *by = [[UITextLabel alloc] initWithFrame: CGRectMake(0,1000,frame.size.width,20)];
        [by setCentersHorizontally: YES];
        [by setFont: font3];
	[by setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)];
	[by setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), byColor)];
        [by setText: byLine];
	[self addSubview: by];

	// animate!
        [UIView beginAnimations:nil];
        [UIView setAnimationCurve: 2];
        [UIView setAnimationDuration: 1];
	[txt setOrigin: CGPointMake(0,0)];
	[by setOrigin: CGPointMake(0,frame.size.height-30)];
	[app setOrigin: CGPointMake(0,226)];
	[ico setOrigin: CGPointMake(130,200)];
	[UIView endAnimations];

	return self;
}

@end
