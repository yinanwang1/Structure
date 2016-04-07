//
//  ChatsEntity.m
//  Structure
//
//  Created by ArthurWang on 16/3/28.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import "ChatsEntity.h"

@implementation ChatsEntity

+ (instancetype)createChatsEntityWithDic:(NSDictionary *)dic
{
    NSDictionary *mapping = @{
                              @"name": @"nameStr",
                              @"age":@"ageIntNum",
                              };
    
    ChatsEntity *entity = [ChatsEntity objectFromJSONObject:dic
                                                    mapping:mapping];
    
    return entity;
}

@end
