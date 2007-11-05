/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <UIKit/UIKit.h>
#import <Celestial/AVItem.h>
#import <Celestial/AVController.h>

@interface App : UIApplication {
	UIWindow *window;
	UITable *table;
	int totalMiles;
	float totalGallons;
	float totalCost;
	float totalMPG;
	float totalCPM;
	float totalCPG;
}

-(void)dealloc;

@end
