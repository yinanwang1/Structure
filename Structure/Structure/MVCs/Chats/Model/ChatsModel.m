//
//  ChatsModel.m
//  Structure
//
//  Created by ArthurWang on 16/3/28.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#import "ChatsModel.h"

@implementation ChatsModel

- (void)fetchData:(void (^)(ErrorCode status, NSString *messageStr, ChatsEntity *chatesEntity))compelte
{
    NSDictionary *paramsDic = @{
                                @"test" : @"test",
                                };
    
    [WebService getRequest:URL_TEST
                parameters:paramsDic
                  encToken:nil
                   isLogin:YES
                   success:^(ErrorCode status, NSString *msg, NSDictionary *data) {
                       if (kNoError != status) {
                           
                           compelte(status, msg, nil);
                           
                           return ;
                       }
                       
                       ChatsEntity *entity = [ChatsEntity createChatsEntityWithDic:data];
                       
                       compelte(status, msg, entity);
                       
                   } failure:^(ErrorCode status, NSString *msg, NSDictionary *data) {
                       compelte(status, msg, nil);
                   }];
}

@end
