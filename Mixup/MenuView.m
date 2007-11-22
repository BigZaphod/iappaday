/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "MenuView.h"
#import <UIKit/UIView-Geometry.h>

@interface Callback : NSObject {
	id target;
	SEL action;
}
+(id)callbackWithTarget: (id)t action: (SEL)act;
-(void)dealloc;
-(void)perform;
@end

@implementation Callback
+(id)callbackWithTarget: (id)t action: (SEL)act
{
	Callback *cb = [[[Callback alloc] init] autorelease];
	cb->target = [t retain];
	cb->action = act;
	return cb;
}
-(void)dealloc
{
	[target release];
	[super dealloc];
}
-(void)perform
{
	[target performSelector: action withObject: nil afterDelay: 0];
}
@end


@implementation MenuView

-(void)addButtonWithTitle: (NSString *)title target: (id)target action: (SEL)selector
{
	[alert addButtonWithTitle: title];
	[targets addObject: [Callback callbackWithTarget: target action: selector] ];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	[[targets objectAtIndex: button-1] perform];
	[sheet dismissAnimated: YES];
}

-(void)dealloc
{
	[targets release];
	[alert release];
	[super dealloc];
}

-(void)showMenu
{
	[alert popupAlertAnimated: YES];
}

-(id)init
{
	[super init];

	CGRect frame = [UIHardware fullScreenApplicationContentRect];
	frame.origin.x = frame.origin.y = 0;
	[super initWithFrame: frame];
	UIImageView *def = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"Default.png"]] autorelease];
	[self addSubview: def];

	targets = [[NSMutableArray alloc] init];

	alert = [[UIAlertSheet alloc] init];
	[alert setDimsBackground: NO];
	[alert setDelegate: self];

	return self;
}

-(id)initWithTitle: (NSString *)title body: (NSString *)body
{
	[self init];
	[alert setTitle: title];
	[alert setBodyText: body];
	return self;
}

@end
