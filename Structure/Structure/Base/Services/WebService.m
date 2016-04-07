
#import "WebService.h"

#import "AFNetworking.h"
#import <CommonCrypto/CommonCrypto.h>
#import "sys/utsname.h"
#import "NSDictionary+Utils.h"

#define STATUS_SUCCESS  @"success"
#define STATUS_ERROR    @"error"
#define STATUS_FAIL     @"fail"
#define NETWORK_ERROR   @"WS_Network_Error"

#define NETWORK_ACTIVITY_NOTIFICATION_NAME @"WS_Network_Activity"

static BOOL activityOn = NO;

@implementation WebService

#pragma mark - Initial Methods

+ (AFHTTPSessionManager *)sharedClient
{
    static AFHTTPSessionManager *_sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        //设置我们的缓存大小 其中内存缓存大小设置10M  磁盘缓存5M
        NSURLCache *cache = [[NSURLCache alloc] initWithMemoryCapacity:10 * 1024 * 1024
                                                          diskCapacity:50 * 1024 * 1024
                                                              diskPath:nil];
        
        [config setURLCache:cache];
        
        _sharedClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:SERVER_URL]
                                                 sessionConfiguration:config];
        
        
        if (nil != _sharedClient)
        {
            AFJSONResponseSerializer *response = [AFJSONResponseSerializer serializer];
            response.removesKeysWithNullValues = YES;
            NSMutableSet *acceptContentTypes = [NSMutableSet setWithSet:response.acceptableContentTypes];
            [acceptContentTypes addObject:@"text/plain"];
            response.acceptableContentTypes = acceptContentTypes;
            _sharedClient.responseSerializer = response;
            
            _sharedClient.requestSerializer = [AFHTTPRequestSerializer serializer];
            
            NSString *userAgent = [NSString stringWithFormat:@"%@/%@; iOS %@; %.0fX%.0f/%0.1f", [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleExecutableKey] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleIdentifierKey], [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"] ?: [[[NSBundle mainBundle] infoDictionary] objectForKey:(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] systemVersion], SCREEN_WIDTH*[[UIScreen mainScreen] scale],SCREEN_HEIGHT*[[UIScreen mainScreen] scale], [[UIScreen mainScreen] scale]];
            if (userAgent) {
                if (![userAgent canBeConvertedToEncoding:NSASCIIStringEncoding]) {
                    NSMutableString *mutableUserAgent = [userAgent mutableCopy];
                    if (CFStringTransform((__bridge CFMutableStringRef)(mutableUserAgent), NULL, (__bridge CFStringRef)@"Any-Latin; Latin-ASCII; [:^ASCII:] Remove", false)) {
                        userAgent = mutableUserAgent;
                    }
                }
            }
        }
    });
    
    return _sharedClient;
}

#pragma mark -
#pragma mark Core

+ (void)handleSuccess:(BOOL)isPost
              isLogin:(BOOL)isLogin
                 path:(NSString*)path
           parameters:(NSDictionary*)parameters
            operation:(NSURLSessionDataTask *)op
                 json:(id)json
              success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
              failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    DLog(@"%@ handleSuccess", path);
    
    [WebService onResponseData:json
                       success:success
                       failure:failure];
    
}

+ (void)handleFailure:(BOOL)isPost
              isLogin:(BOOL)isLogin
                 path:(NSString*)path
           parameters:(NSDictionary*)parameters
            operation:(NSURLSessionDataTask *)op
                error:(NSError*)error
              success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
              failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_ERROR object:self userInfo:@{@"error": error}];
    
    failure(kNetWorkError, @"网络错误", nil);
}


#pragma mark - Public Methods

#pragma mark - POST

+ (NSURLSessionDataTask *)postRequest:(NSString*)path
                           parameters:(id)parameters
                             encToken:(NSString*)encToken
                              isLogin:(BOOL)isLogin
                              success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                              failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure

{
    DLog(@"Request Start %@", [NSDate date]);
    DLog(@"Request %@", path);
    DLog(@"Params %@", parameters);
    
    [WebService activity:YES];
    
    parameters = [WebService signDictionary:parameters];
    
    NSURLSessionDataTask *task = [WebService postPath:path
                                           parameters:parameters
                                             encToken:encToken
                                              isLogin:isLogin
                                              success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 
                                                 [WebService handleSuccess:YES
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                      json:responseObject
                                                                   success:success
                                                                   failure:failure];
                                                 
                                                 [WebService activity:NO];
                                              } failure:^(NSURLSessionDataTask *task, NSError *error) {

                                                 DLog(@"Request End Faile %@", [NSDate date]);
                                                 [WebService handleFailure:YES
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                     error:error
                                                                   success:success
                                                                   failure:failure];
                                                 
                                                 [WebService activity:NO];
                                              }];
    
    
    return task;
}

+ (NSURLSessionDataTask *)postPath:(NSString *)path
                        parameters:(id)parameters
                          encToken:(NSString*)encToken
                           isLogin:(BOOL)isLogin
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [WebService sharedClient];
    
    DLog(@"[request allHTTPHeaderFields] is %@.", manager.requestSerializer);
    
    NSURLSessionDataTask *task = [manager POST:path parameters:parameters success:success failure:failure];
    
    return task;
}


#pragma mark - GET

+ (NSURLSessionDataTask *)getRequest:(NSString*)path
                          parameters:(NSDictionary*)parameters
                            encToken:(NSString*)encToken
                             isLogin:(BOOL)isLogin
                             success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                             failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    DLog(@"Request Start %@", [NSDate date]);
    DLog(@"Request %@", path);
    DLog(@"Params %@", parameters);
    
    parameters = [WebService signDictionary:parameters];
    
    NSURLSessionDataTask *task = [WebService getPath:path parameters:parameters
                                            encToken:encToken
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 
                                                 [WebService handleSuccess:NO
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                      json:responseObject
                                                                   success:success
                                                                   failure:failure];
                                             } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                 
                                                 DLog(@"Request End Faile %@", [NSDate date]);
                                                 
                                                 [WebService handleFailure:NO
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                     error:error
                                                                   success:success
                                                                   failure:failure];
                                             }];
    
    return task;
}

+ (NSURLSessionDataTask *)getPath:(NSString *)path
                       parameters:(NSDictionary *)parameters
                         encToken:(NSString*)encToken
                          success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                          failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [WebService sharedClient];
    
    DLog(@"get [request allHTTPHeaderFields] is %@.", manager.requestSerializer);
    
    NSURLSessionDataTask *task = [manager GET:path parameters:parameters success:success failure:failure];
    
    return task;
    
}


#pragma mark - UPLOAD

+ (NSURLSessionDataTask *)uploadRequest:(NSString*)path
                             parameters:(NSDictionary*)parameters
                               encToken:(NSString*)encToken
                          formDataArray:(NSArray *)formDataArray
                                isLogin:(BOOL)isLogin
                                success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                                failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    DLog(@"Request Start %@", [NSDate date]);
    DLog(@"Request %@", path);
    DLog(@"Params %@", parameters);
    
    parameters = [WebService signDictionary:parameters];
    
    [WebService activity:YES];
    NSURLSessionDataTask *task = [WebService uploadPath:path
                                             parameters:parameters
                                               encToken:encToken
                              constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
                                [formData appendPartWithFileData:[formDataArray objectAtIndex:0]
                                                            name:[formDataArray objectAtIndex:1]
                                                        fileName:[formDataArray objectAtIndex:2]
                                                        mimeType:[formDataArray objectAtIndex:3]];
                              }
                                                success:^(NSURLSessionDataTask *task, id responseObject) {
					   
                                                   DLog(@"Request End Success %@", [NSDate date]);
                                                   NSDictionary *jsonDict = (NSDictionary *)[responseObject dictionaryByReplacingNullsWithStrings];
                                                   [WebService handleSuccess:YES
                                                                     isLogin:isLogin
                                                                        path:path
                                                                  parameters:parameters
                                                                   operation:task
                                                                        json:jsonDict
                                                                     success:success
                                                                     failure:failure];
                                                   
                                                   [WebService activity:NO];
                                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                     DLog(@"Request End Faile %@", [NSDate date]);
                                                     [WebService handleFailure:YES
                                                                       isLogin:isLogin
                                                                          path:path
                                                                    parameters:parameters
                                                                     operation:task
                                                                         error:error
                                                                       success:success
                                                                       failure:failure];
                                                     
                                                     [WebService activity:NO];
                                                }];
    
    
    return task;
}


+ (NSURLSessionDataTask *)uploadPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                            encToken:(NSString*)encToken
           constructingBodyWithBlock:(void (^)(id <AFMultipartFormData> formData))block
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [WebService sharedClient];
    
    NSURLSessionDataTask *task = [manager POST:path parameters:parameters constructingBodyWithBlock:block success:success failure:failure];
    
    return task;
}


#pragma mark - PUT

+ (NSURLSessionDataTask *)putRequest:(NSString*)path
                          parameters:(NSDictionary*)parameters
                            encToken:(NSString*)encToken
                             isLogin:(BOOL)isLogin
                             success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                             failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    DLog(@"Request Start %@", [NSDate date]);
    DLog(@"Request %@", path);
    DLog(@"Params %@", parameters);
    
    parameters = [WebService signDictionary:parameters];
    
    [WebService activity:YES];
    NSURLSessionDataTask *task = [WebService putPath:path
                                          parameters:parameters
                                            encToken:encToken
                                             isLogin:isLogin
                                             success:^(NSURLSessionDataTask *task, id responseObject) {
                                                 
                                                 [WebService handleSuccess:YES
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                      json:responseObject
                                                                   success:success
                                                                   failure:failure];
                                                 
                                                 [WebService activity:NO];
                                             } failure:^(NSURLSessionDataTask *task, NSError *error) {

                                                 DLog(@"Request End Faile %@", [NSDate date]);
                                                 [WebService handleFailure:YES
                                                                   isLogin:isLogin
                                                                      path:path
                                                                parameters:parameters
                                                                 operation:task
                                                                     error:error
                                                                   success:success
                                                                   failure:failure];
                                                 
                                                 [WebService activity:NO];
                                             }];
    
    return task;
}


+ (NSURLSessionDataTask * )putPath:(NSString *)path
                        parameters:(NSDictionary *)parameters
                          encToken:(NSString*)encToken
                           isLogin:(BOOL)isLogin
                           success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                           failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [WebService sharedClient];
    
    NSURLSessionDataTask *task = [manager PUT:path parameters:parameters success:success failure:failure];
    
    return task;
  
}


#pragma mark - DELETE

+ (NSURLSessionDataTask *)deleteRequest:(NSString*)path
                             parameters:(NSDictionary*)parameters
                               encToken:(NSString*)encToken
                                isLogin:(BOOL)isLogin
                                success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
                                failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    DLog(@"Request Start %@", [NSDate date]);
    DLog(@"Request %@", path);
    DLog(@"Params %@", parameters);
    
    parameters = [WebService signDictionary:parameters];
    
    [WebService activity:YES];
    NSURLSessionDataTask *task = [WebService deletePath:path
                                             parameters:parameters
                                               encToken:encToken
                                                isLogin:isLogin
                                                success:^(NSURLSessionDataTask *task, id responseObject) {
                                                    
                                                    [WebService handleSuccess:YES
                                                                      isLogin:isLogin
                                                                         path:path
                                                                   parameters:parameters
                                                                    operation:task
                                                                         json:responseObject
                                                                      success:success
                                                                      failure:failure];
                                                    
                                                    [WebService activity:NO];
                                                } failure:^(NSURLSessionDataTask *task, NSError *error) {
                                                    
                                                     DLog(@"Request End Faile %@", [NSDate date]);
                                                     [WebService handleFailure:YES
                                                                       isLogin:isLogin
                                                                          path:path
                                                                    parameters:parameters
                                                                     operation:task
                                                                         error:error
                                                                       success:success
                                                                       failure:failure];
                                                     
                                                     [WebService activity:NO];
                                                }];
    
    return task;
}


+ (NSURLSessionDataTask *)deletePath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                            encToken:(NSString*)encToken
                             isLogin:(BOOL)isLogin
                             success:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                             failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure
{
    AFHTTPSessionManager *manager = [WebService sharedClient];
    
    NSURLSessionDataTask *task = [manager DELETE:path parameters:parameters success:success failure:failure];
    
    return task;
    
}


#pragma mark - Private Methods

+ (NSDictionary *)signDictionary:(NSDictionary *)dic
{
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSMutableString *start = [[NSMutableString alloc] init];
        NSMutableDictionary *dicReal = [NSMutableDictionary dictionaryWithDictionary:dic];
        if (dicReal == nil) {
            dicReal = [NSMutableDictionary dictionary];
        }
        
        // 添加签名
        
        return dicReal;
    } else {
        return [NSDictionary dictionary];
    }
}

+ (void)onResponseData:(id)responseObject
               success:(void (^)(ErrorCode status, NSString * msg, NSDictionary * data))success
               failure:(void (^)(ErrorCode status, NSString *msg, NSDictionary * data))failure
{
    id json = responseObject;
    
    if(json && [json isKindOfClass:[NSDictionary class]]) {
        // json 进行解析，返回数据
        NSDictionary *data = [[NSDictionary alloc] init];
        success(kNoError, @"成功", data);
    }else {
        failure(kUnknownError, @"未知错误-1002", nil);
    }
}

+ (void)activity:(BOOL)on
{
    if(on && !activityOn)
    {
        activityOn = YES;
        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_ACTIVITY_NOTIFICATION_NAME object:self userInfo:@{@"on": [NSNumber numberWithBool:on]}];
    }
    else if(!on && activityOn)
    {
        activityOn = NO;
        [[NSNotificationCenter defaultCenter] postNotificationName:NETWORK_ACTIVITY_NOTIFICATION_NAME object:self userInfo:@{@"on": [NSNumber numberWithBool:on]}];
    }
}

+ (NSString *)webServiceCurrentDateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSDate *now = [[NSDate alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy HH:mm:ss"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    return [dateFormatter stringFromDate:now];
}



@end
