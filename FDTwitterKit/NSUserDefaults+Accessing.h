#import <Foundation/Foundation.h>


#pragma mark Class Interface

@interface NSUserDefaults (Accessing)


#pragma mark - Instance Methods

- (void)archiveAndSetObject: (id<NSCoding>)object forKey:(NSString *)key;
- (id)unarchivedObjectForKey: (NSString *)key;


@end