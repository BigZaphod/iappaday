/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>
#import <UIKit/UIView-Animation.h>

static NSString* MONTHS[12] = {
	@"Jan",
	@"Feb",
	@"Mar",
	@"Apr",
	@"May",
	@"Jun",
	@"Jul",
	@"Aug",
	@"Sep",
	@"Oct",
	@"Nov",
	@"Dec"
};

@implementation App
- (int)numberOfColumnsInPickerView: (UIPickerView*)p
{
        return 6;
}

-(void)updateTime
{
	NSCalendarDate *now = [NSCalendarDate calendarDate];

	int hour = [datePicker selectedRowForColumn: 3];
	if( [datePicker selectedRowForColumn: 5] == 1 ) hour += 12;

	NSCalendarDate *then = [[[NSCalendarDate alloc]
		initWithYear: [datePicker selectedRowForColumn: 2] + 1000
		month: [datePicker selectedRowForColumn: 0] + 1
		day: [datePicker selectedRowForColumn: 1]+1
		hour: hour+1
		minute: [datePicker selectedRowForColumn: 4]
		second: 0
		timeZone: [now timeZone]] autorelease];

	int years;
	int months;
	int days;
	int hours;
	int minutes;
	int seconds;

	[now years: &years months: &months days: &days hours: &hours minutes: &minutes seconds: &seconds sinceDate: then];

	years = abs(years);
	months = abs(months);
	days = abs(days);
	hours = abs(hours);
	minutes = abs(minutes);
	seconds = abs(seconds);

	[yearsText setText: [NSString stringWithFormat: @"%d year%s", years, (years==1)? "": "s"]];
	[monthsText setText: [NSString stringWithFormat: @"%d month%s", months, (months==1)? "": "s"]];
	[daysText setText: [NSString stringWithFormat: @"%d day%s", days, (days==1)? "": "s"]];
	[hoursText setText: [NSString stringWithFormat: @"%d hour%s", hours, (hours==1)? "": "s"]];
	[minutesText setText: [NSString stringWithFormat: @"%d minute%s", minutes, (minutes==1)? "": "s"]];
	[secondsText setText: [NSString stringWithFormat: @"%d second%s", seconds, (seconds==1)? "": "s"]];

	[self performSelector: @selector(updateTime) withObject: nil afterDelay: 1];
}

- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col
{
	switch( col ) {
	case 0: return 12;
	case 1: return 31;
	case 2: return 2000;
	case 3: return 12;
	case 4: return 60;
	case 5: return 2;
	}
}

- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col
{
        id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	switch( col ) {
	case 0:
		[cell setAlignment: 2];
		[cell setTitle: MONTHS[row]];
		break;
	case 1:
		[cell setAlignment: 2];
		[cell setTitle: [NSString stringWithFormat:@"%d",row+1]];
		break;
	case 2:
		[cell setAlignment: 2];
		[cell setTitle: [NSString stringWithFormat:@"%d", 1000+row]];
		break;
	case 3:
		[cell setAlignment: 3];
		[cell setTitle: [NSString stringWithFormat:@"%d", 1+row]];
		break;
	case 4:
		[cell setAlignment: 2];
		[cell setTitle: [NSString stringWithFormat:@"%02d", row]];
		break;
	case 5:
		[cell setAlignment: 2];
		[cell setTitle: row? @"PM": @"AM"];
		break;
	}
        return cell;
}

-(float)pickerView:(UIPickerView*)p tableWidthForColumn: (int)col
{
	switch( col ) {
	case 0: return 54;
	case 1: return 43;
	case 2: return 62;
	case 3: return 43;
	case 4: return 43;
	case 5: return 43;
	}
}

-(void)pickerViewLoaded: (UIPickerView*)p
{
	NSCalendarDate *now = [NSCalendarDate calendarDate];
	int hour = [now hourOfDay];
	BOOL pm = NO;
	if( hour > 12 ) {
		hour -= 12;
		pm = YES;
	}
	if( hour == 0 ) hour = 12;
	[p selectRow: [now monthOfYear]-1 inColumn: 0 animated: NO];
	[p selectRow: [now dayOfMonth]-1 inColumn: 1 animated: NO];
	[p selectRow: [now yearOfCommonEra]-1000 inColumn: 2 animated: NO];
	[p selectRow: hour-1 inColumn: 3 animated: NO];
	[p selectRow: [now minuteOfHour] inColumn: 4 animated: NO];
	[p selectRow: pm? 1: 0 inColumn: 5 animated: NO];
	[self updateTime];
}

-(void)mainScreenTurnOn
{
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];

	CGSize s = [UIPickerView defaultSize];
	datePicker = [[UIPickerView alloc] initWithFrame: CGRectMake(0,[window bounds].size.height-s.height,s.width,s.height)];
	[datePicker setDelegate: self];
	[v addSubview: datePicker];

	CGRect r = [datePicker selectionBarRect];
	r.origin.y += [datePicker origin].y;
        UIView *bar = [[[UIView alloc] initWithFrame: r] autorelease];
        [bar setAlpha: 0.2];
        [bar setEnabled: NO];
        float bgColor[] = { 0.2, 0.2, 0.2, 1 };
        [bar setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
        [v addSubview: bar];

        float alphaColor[] = { 0, 0, 0, 0 };
        float txtColor[] = { 1, 1, 1, 1 };

	int spacer = 0;
	#define LABEL(n) \
	n = [[UITextLabel alloc] initWithFrame: CGRectMake(0,0,[window bounds].size.width,30)]; \
	[n setCentersHorizontally: YES]; \
	[n setOrigin: CGPointMake(0,(++spacer * 30))]; \
	[n setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), alphaColor)]; \
	[n setColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), txtColor)]; \
	[v addSubview: n];

	LABEL( yearsText );
	LABEL( monthsText );
	LABEL( daysText );
	LABEL( hoursText );
	LABEL( minutesText );
	LABEL( secondsText );

	[window setContentView: v];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Interval" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(mainScreenTurnOn)];
	[window setContentView: s];
}

-(void)dealloc
{
	[yearsText release];
	[monthsText release];
	[daysText release];
	[hoursText release];
	[minutesText release];
	[secondsText release];
	[datePicker release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 0, 0, 0, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];

	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
