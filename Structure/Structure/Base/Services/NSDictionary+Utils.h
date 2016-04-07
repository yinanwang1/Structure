

#import <Foundation/Foundation.h>

@interface NSDictionary (Utils)

- (NSDictionary *)dictionaryByReplacingNullsWithStrings;
- (id)objectForKeyExpectNSNull:(id)aKey;
- (id)objectForKeyExpectNil:(id)aKey;

@end
