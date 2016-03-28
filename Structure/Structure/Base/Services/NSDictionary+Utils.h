//
//  NSDictionary+Utils.h
//  StudentInfo
//
//  Created by Sai Chow on 2/12/14.
//  Copyright (c) 2014 Netchemia. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Utils)

- (NSDictionary *)dictionaryByReplacingNullsWithStrings;
- (id)objectForKeyExpectNSNull:(id)aKey;
- (id)objectForKeyExpectNil:(id)aKey;

@end
