#import "NSUserDefaults+Accessing.h"


#pragma mark Class Definition

@implementation NSUserDefaults (Accessing)


#pragma mark - Public Methods

- (void)archiveAndSetObject: (id<NSCoding>)object forKey:(NSString *)key
{
	NSData *data = [NSKeyedArchiver archivedDataWithRootObject: object];
	
	[self setObject: data 
		forKey: key];
}

- (id)unarchivedObjectForKey: (NSString *)key
{
	id object = nil;
	
	NSData *data = [self objectForKey: key];
	if (data != nil)
	{
		object =  [NSKeyedUnarchiver unarchiveObjectWithData: data];
	}
	
	return object;
}


@end