#import "CategoryList.h"

static NSString *dataPath = @"/var/root/Library/Leftover/record.plist";

@implementation CategoryList

+(NSMutableArray*)loadData
{
	NSMutableArray *a = [[NSMutableArray alloc] initWithContentsOfFile: dataPath];
	if( !a ) a = [[NSMutableArray alloc] init];
	return [a autorelease];
}

+(void)saveData: (NSMutableArray*)d
{
	[[NSFileManager defaultManager] createDirectoryAtPath: [dataPath stringByDeletingLastPathComponent] attributes: nil];
	[d writeToFile: dataPath atomically: YES];
}

+(void)addCategoryWithName: (NSString*)name initialValue: (float)amount
{
	NSDictionary *dict = [[[NSDictionary alloc] initWithObjectsAndKeys:
		name,					@"name",
		[NSNumber numberWithFloat: amount],	@"amount",
	nil] autorelease];

	id data = [self loadData];
	[data addObject: dict];
	[self saveData: data];
}

// this stuff is pretty terrible, really...  going to the filesystem way too much.. but I'm in a rush :)

+(void)deleteCategoryAtIndex: (int)i
{
	id data = [self loadData];
	[data removeObjectAtIndex: i];
	[self saveData: data];
}

+(void)moveCategoryAtIndex: (int)i toIndex: (int)t
{
	id data = [self loadData];
	[data exchangeObjectAtIndex: i withObjectAtIndex: t];
	[self saveData: data];
}

+(int)count
{
	return [[self loadData] count];
}

+(NSString*)categoryNameAtIndex: (int)i
{
	return [[[self loadData] objectAtIndex: i] objectForKey: @"name"];
}

+(float)categoryValueAtIndex: (int)i
{
	return [[[[self loadData] objectAtIndex: i] objectForKey: @"amount"] floatValue];
}

+(void)addValue: (float)v toCategoryAtIndex: (int)i
{
	id data = [self loadData];
	id cat = [data objectAtIndex: i];
	NSNumber *amount = [cat objectForKey: @"amount"];
	[cat removeObjectForKey: @"amount"];
	[cat setObject: [NSNumber numberWithFloat: [amount floatValue]+v] forKey: @"amount"];
	[self saveData: data];
}

@end
