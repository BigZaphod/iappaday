/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import "App.h"
#import "AddWindow.h"
#import "SplashView.h"
#import <UIKit/UIView-Geometry.h>

NSString *dataPath = @"/var/root/Library/Pumped/log.plist";

@implementation App

- (int)numberOfRowsInTable:(UITable*)table
{
	return 6;
}

- (UITableCell*)table:(UITable*)table cellForRow:(int)row column:(UITableColumn *)column
{
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];

	if( row == 0 && [column identifier] == @"name" ) [cell setTitle: @"Miles Traveled"];
	if( row == 0 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"%d", totalMiles]];

	if( row == 1 && [column identifier] == @"name" ) [cell setTitle: @"Gallons Used"];
	if( row == 1 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"%0.1f", totalGallons]];

	if( row == 2 && [column identifier] == @"name" ) [cell setTitle: @"Total Fuel Cost"];
	if( row == 2 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"$%0.2f", totalCost]];

	if( row == 3 && [column identifier] == @"name" ) [cell setTitle: @"Miles Per Gallon"];
	if( row == 3 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"%0.1f", totalMPG]];

	if( row == 4 && [column identifier] == @"name" ) [cell setTitle: @"Cost Per Mile"];
	if( row == 4 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"$%0.2f", totalCPM]];

	if( row == 5 && [column identifier] == @"name" ) [cell setTitle: @"Cost Per Gallon"];
	if( row == 5 && [column identifier] == @"value" ) [cell setTitle: [NSString stringWithFormat: @"$%0.2f", totalCPG]];

	return cell;
}

-(void)loadValues
{
	totalMiles = 0;
	totalGallons = 0;
	totalCost = 0;
	totalMPG = 0;
	totalCPM = 0;
	totalCPG = 0;

	NSArray *a = [NSArray arrayWithContentsOfFile: dataPath];
	if( [a count] == 1 ) {
		NSDictionary *d = [a objectAtIndex: 0];
		totalGallons = [[d objectForKey: @"gallons"] floatValue];
		totalCPG = [[d objectForKey: @"price"] floatValue];
		totalCost = totalGallons * totalCPG;
	} else if( [a count] > 1) {
		int i;
		for( i=0; i<[a count]; i++ ) {
			NSDictionary *d = [a objectAtIndex: i];
			float gallons = [[d objectForKey: @"gallons"] floatValue];
			float price = [[d objectForKey: @"price"] floatValue];
			totalGallons += gallons;
			totalCost += price * gallons;
		}

		totalMiles = [[[a objectAtIndex: [a count]-1] objectForKey: @"miles"] intValue] - [[[a objectAtIndex: 0] objectForKey: @"miles"] intValue];
		totalMPG = totalMiles / totalGallons;
		totalCPM = totalCost / totalMiles;
		totalCPG = totalCost / totalGallons;
	}

	[table reloadData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
}

-(void)completedAddWindow:(AddWindow *)win withDictionary:(NSDictionary *)dict
{
	[[NSFileManager defaultManager] createDirectoryAtPath: [dataPath stringByDeletingLastPathComponent] attributes: nil];
	NSMutableArray *a = [[NSMutableArray alloc] initWithContentsOfFile: dataPath];
	if( !a ) a = [[NSMutableArray alloc] init];
	[a autorelease];
	[a addObject: dict];
	[a writeToFile: dataPath atomically: YES];
	[self loadValues];

	/*
	// decided I didn't really care and din't have the time to add a backend.. big deal :)
	NSString *zip = [dict objectForKey: @"zip"];
	float price = [[dict objectForKey: @"price"] floatValue];
	if( zip && price ) {
		NSURLRequest* urlRequest = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://pumped.iappaday.com/fuel.php?z=%s&p=%0.2f", [zip cString], price]]] autorelease];
		[NSURLConnection connectionWithRequest: urlRequest delegate: self];
	}
	*/
}

-(void)closedAddWindow:(AddWindow *)win 
{
	[win release];
}

-(void)showInput
{
	AddWindow *w = [[AddWindow alloc] init];
	[w setDelegate: self];
	[w openWindow];
}

- (void)alertSheet:(UIAlertSheet*)sheet buttonClicked:(int)button
{
	if( button == 1 ) {
		[[NSFileManager defaultManager] removeFileAtPath: dataPath handler: nil];
		[self loadValues];
	}
	[sheet dismissAnimated: YES];
	[sheet release];
}

- (void)navigationBar:(UINavigationBar*)navbar buttonClicked:(int)button
{
	if( button == 1 ) {
		UIAlertSheet *alert = [[UIAlertSheet alloc] init];
		[alert setDelegate: self];
		[alert setBodyText: @"Are you sure you want to reset?"];
		[alert setAlertSheetStyle:1];
		[alert setDestructiveButton: [alert addButtonWithTitle: @"Reset the log"]];
		[alert addButtonWithTitle: @"Cancel"];
		[alert popupAlertAnimated: YES];
	} else {
		[self showInput];
	}
}

-(void)showInterface
{
	UIView *v = [[[UIView alloc] initWithFrame: [window bounds]] autorelease];

	UIImageView *title = [[[UIImageView alloc] initWithImage: [UIImage applicationImageNamed:@"title.png"]] autorelease];
	[v addSubview: title];
	float th = 115;

	CGSize s = [UINavigationBar defaultSize];
	UINavigationBar *bar = [[[UINavigationBar alloc] initWithFrame: CGRectMake(0,[v bounds].size.height-s.height,s.width,s.height)] autorelease];
	[bar showButtonsWithLeftTitle: @"Reset" rightTitle: @"Add New Fuel Record"];
	[bar setDelegate: self];
	[v addSubview: bar];

	CGSize vs = [v bounds].size;
	table = [[UITable alloc] initWithFrame: CGRectMake(0,th,vs.width,vs.height-s.height-th)];
	[table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"" identifier:@"name" width:180] autorelease]];
	[table addTableColumn: [[[UITableColumn alloc] initWithTitle:@"" identifier:@"value" width:140] autorelease]];
	[table setDataSource: self];
	[v addSubview: table];
	[self loadValues];

	[window setContentView: v];
}

-(void)showSplash
{
	SplashView *s = [[[SplashView alloc] initWithName: @"Pumped" andAuthor:@"Sean Heber <sean@spiffytech.com>"] autorelease];
	[s continueTarget: self action: @selector(showInterface)];
	[window setContentView: s];
}

-(void)dealloc
{
	[table release];
	[super dealloc];
}

- (void)applicationDidFinishLaunching: (id) unused
{
	window = [[UIWindow alloc] initWithContentRect: [UIHardware fullScreenApplicationContentRect]];
	float bgColor[] = { 1, 1, 1, 1 };
	[window setBackgroundColor: CGColorCreate(CGColorSpaceCreateDeviceRGB(), bgColor)];
	[window orderFront: self];
	[window makeKey: self];

	[self showSplash];
}

@end
