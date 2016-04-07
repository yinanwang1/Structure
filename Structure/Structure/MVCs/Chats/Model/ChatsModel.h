//
//  ChatsModel.h
//  Structure
//
//  Created by ArthurWang on 16/3/28.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ChatsEntity.h"

@interface ChatsModel : NSObject

- (void)fetchData:(void (^)(ErrorCode status, NSString *messageStr, ChatsEntity *chatesEntity))compelte;

@end
