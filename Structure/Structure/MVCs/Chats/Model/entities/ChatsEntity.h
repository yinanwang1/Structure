//
//  ChatsEntity.h
//  Structure
//
//  Created by ArthurWang on 16/3/28.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ChatsEntity : NSObject

@property (nonatomic, strong) NSString *nameStr;
@property (nonatomic, strong) NSNumber *ageIntNum;

+ (instancetype)createChatsEntityWithDic:(NSDictionary *)dic;

@end
