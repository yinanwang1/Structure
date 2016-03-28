//
//  Utilities.h
//  Structure
//
//  Created by ArthurWang on 16/3/28.
//  Copyright © 2016年 Arthur. All rights reserved.
//

#ifndef Utilities_h
#define Utilities_h

#if     DEBUG
#       define DLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#       define breakpoint(e)  assert(e)//在调试模式下，如果程序进入不期望进入的分支，assert出来,如果在非调试模式下忽略
#else
#       define DLog(...)
#       define breakpoint(e)
#endif

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define UIColorFromRGBA(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF000000) >> 24))/255.0 green:((float)((rgbValue & 0xFF0000) >> 16))/255.0 blue:((float)((rgbValue & 0xFF00) >> 8))/255.0 alpha:((float)(rgbValue & 0xFF))/255.0]

#define DIC_HAS_STRING(dic, key)  ([dic objectForKey:key] && [[dic objectForKey:key] isKindOfClass:[NSString class]])

#define DIC_HAS_NUMBER(dic, key)  ([dic objectForKey:key] && [[dic objectForKey:key] isKindOfClass:[NSNumber class]])

#define DIC_HAS_ARRAY(dic, key)  ([dic objectForKey:key] && [[dic objectForKey:key] isKindOfClass:[NSArray class]])

#define DIC_HAS_DIC(dic, key)  ([dic objectForKey:key] && [[dic objectForKey:key] isKindOfClass:[NSDictionary class]])

#define DIC_HAS_MEM(dic, key, className)  ([dic objectForKey:key] && [[dic objectForKey:key] isKindOfClass:[className class]])

#define DIC_MEM_NOT_NULL(dic, key) ([dic objectForKey:key] && ![[dic objectForKey:key] isKindOfClass:[NSNull class]])

#define SCREEN_HEIGHT               ([UIScreen mainScreen].bounds.size.height)
#define SCREEN_WIDTH                ([UIScreen mainScreen].bounds.size.width)
#define IPAD_PORTRAIT (IPAD && ([UIDevice currentDevice].orientation == 1 || [UIDevice currentDevice].orientation == 2)
#define IPAD_LANDSCAPE (IPAD && ([UIDevice currentDevice].orientation == 3 || [UIDevice currentDevice].orientation == 4))

#define GLOBAL_NORMAL_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
#define GLOBAL_LOW_QUEUE dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)

#define BEGIN_MAIN_THREAD dispatch_async(dispatch_get_main_queue(), ^(){
#define END_MAIN_THREAD   });

#define BEGIN_MAIN_THREAD_SYNC dispatch_async(dispatch_get_main_queue(), ^(){
#define END_MAIN_THREAD_SYNC   });

#define BEGIN_BACKGROUND_THREAD dispatch_async(GLOBAL_NORMAL_QUEUE, ^(){
#define END_BACKGROUND_THREAD   });

#define BEGIN_LOW_THREAD dispatch_async(GLOBAL_LOW_QUEUE, ^(){
#define END_LOW_THREAD   });


#endif /* Utilities_h */
