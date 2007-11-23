/*
        By: Sean Heber  <sean@spiffytech.com>
        iApp-a-Day - November, 2007
        BSD License
*/
#import <Foundation/Foundation.h>

@interface CategoryList : NSObject {
}

+(void)addCategoryWithName: (NSString*)name initialValue: (float)amount;
+(void)deleteCategoryAtIndex: (int)i;
+(void)moveCategoryAtIndex: (int)i toIndex: (int)t;

+(int)count;
+(NSString*)categoryNameAtIndex: (int)i;
+(float)categoryValueAtIndex: (int)i;
+(void)addValue: (float)v toCategoryAtIndex: (int)i;

@end
