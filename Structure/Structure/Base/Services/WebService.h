
#import <Foundation/Foundation.h>

@class AFHTTPSessionManager;

@interface WebService : NSObject

+ (AFHTTPSessionManager *)sharedClient;

+ (NSURLSessionDataTask *)postRequest:(NSString*)path
                           parameters:(id)parameters
                             encToken:(NSString*)encToken
                              isLogin:(BOOL)isLogin
                              success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                              failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure;

+ (NSURLSessionDataTask *)getRequest:(NSString*)path
                          parameters:(NSDictionary*)parameters
                            encToken:(NSString*)encToken
                             isLogin:(BOOL)isLogin
                             success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                             failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure;

+ (NSURLSessionDataTask *)uploadRequest:(NSString*)path
                             parameters:(NSDictionary*)parameters
                               encToken:(NSString*)encToken
                          formDataArray:(NSArray *)formDataArray
                                isLogin:(BOOL)isLogin
                                success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                                failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure;

+ (NSURLSessionDataTask *)putRequest:(NSString*)path
                          parameters:(NSDictionary*)parameters
                            encToken:(NSString*)encToken
                             isLogin:(BOOL)isLogin
                             success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                             failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure;

+ (NSURLSessionDataTask *)deleteRequest:(NSString*)path
                             parameters:(NSDictionary*)parameters
                               encToken:(NSString*)encToken
                                isLogin:(BOOL)isLogin
                                success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                                failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure;


@end
