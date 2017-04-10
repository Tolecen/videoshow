 

#import "AppRequestSender.h"
#import "AFNetworking.h"
#import "NSDictionary+LocalLog.h"
#import "NSString+md5.h"

#import<CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>

@interface AppRequestSender()

@property (nonatomic,strong) AFURLSessionManager * manager;

@property (nonatomic, strong) AFHTTPSessionManager *sessionManager;

@end


@implementation AppRequestSender

static  AppRequestSender *RequestSender;

+ (AppRequestSender *) shareRequestSender;
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        RequestSender = [AppRequestSender new];
    });
    return  RequestSender;
}

- (AFURLSessionManager *)manager
{
    if (_manager == nil) {
        
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        AFHTTPResponseSerializer *response = [AFHTTPResponseSerializer serializer];
        response.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _manager.responseSerializer = response;
    }
    return _manager;
}

- (AFHTTPSessionManager *) sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [AFHTTPSessionManager manager];
        _sessionManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        _sessionManager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript",@"text/html", nil];
        _sessionManager.requestSerializer.timeoutInterval = 10;
    }
    return _sessionManager;
}


- (void) requestMethod:(HTTP_Method)method
             URLString:(NSString *)URLString
            parameters:(NSDictionary *)parameters
         successHandle:(SuccessHandle)success
         failureHandle:(FailureHandle)failure
{
    NSString *method_string;
    switch (method) {
        case POST:
            method_string = @"POST";
        break;
        case GET:
            method_string = @"GET";
        break;
        case DELETE:
            method_string = @"DELETE";
        break;
        case PUT:
            method_string = @"PUT";
        break;
        default:
        break;
    }

    
    //设置默认签名 默认令牌 默认时间戳
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    //    [AppDataManager defaultManager];
    //    [AppDataManager defaultManager];
    [dict setValue:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [dict setValue:[AppDataManager defaultManager].identifier forKey:@"token"];
    [dict setValue:Sign_Salt forKey:@"key"];
    dict = [self paramerOfSign:dict withMethod:method_string withUrlString:URLString];
    
    URLString = [URLManager requestURLGenerateWithURL:URLString];
    URLString = [URLString stringByRemovingPercentEncoding];
    
    NSLog(@">>>>> path: %@\nparam:%@", URLString, dict);
    
    NSString *tempMethod;
    
    switch (method) {
        case POST:
        {
            tempMethod = @"POST";
            
            [self.sessionManager POST:URLString parameters:dict progress:^(NSProgress * _Nonnull uploadProgress) {
                
            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (responseObject) {
                    NSError *jsonError;
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                    if (!jsonError) {
                        
                        success(result);
                    }
                    NSLog(@"result = %@ ----  jsonError = %@",[result descriptionWithLocale:result],jsonError);
                    
                    if (jsonError) {
                        //转码
                        NSString *stringT = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        NSLog(@"stringT=%@ \n jsonError=%@",stringT,jsonError);
                        failure(jsonError);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@",error);
                failure(error);
            }];
        }
            break;
        case GET:
        {
            tempMethod = @"GET";
            
            [self.sessionManager GET:URLString parameters:dict progress:^(NSProgress * _Nonnull downloadProgress) {
                

            } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (responseObject) {
                    NSError *jsonError;
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                    if (!jsonError) {
                        
                        success(result);
                    }
                    NSLog(@"result = %@ ----  jsonError = %@",[result descriptionWithLocale:result],jsonError);
                    
                    if (jsonError) {
                        //转码
                        NSString *stringT = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        NSLog(@"string=====%@ \n jsonError=%@",stringT,jsonError);
                        failure(jsonError);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@",error);
                failure(error);
            }];
        }
            break;
        case PUT:
        {
            tempMethod = @"PUT";
            
            [self.sessionManager PUT:URLString parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@",error);
            }];
        }
            break;
        case DELETE:
        {
            tempMethod = @"DELETE";
            
            [self.sessionManager DELETE:URLString parameters:dict success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                if (responseObject) {
                    NSError *jsonError;
                    NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
                    if (!jsonError) {
                
                        success(result);
                    }
                    
                    NSLog(@"result = %@ ----  jsonError = %@",[result descriptionWithLocale:result],jsonError);
                    
                    if (jsonError) {
                        //转码
                        NSString *stringT = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                        NSLog(@"stringT=%@ \n jsonError=%@",stringT,jsonError);
                        failure(jsonError);
                    }
                }
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                NSLog(@"error = %@",error);
                failure(error);
            }];
        }
            break;
        default:
            break;
    }
}
 
- (void) uploadFileWithURLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                       ImageData:(NSData *)imageData
                        fileName:(NSString *)fileName
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                   successHandle:(SuccessHandle)success
                   failureHandle:(FailureHandle)failure
                  progressHandle:(ProgressHandle)progress1;

{
    //设置默认签名 默认令牌 默认时间戳
    NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [dict setValue:[NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]] forKey:@"timestamp"];
    [dict setValue:[AppDataManager defaultManager].identifier forKey:@"token"];
    [dict setValue:Sign_Salt forKey:@"key"];
    dict = [self paramerOfSign:dict withMethod:@"POST" withUrlString:URLString];
    
    URLString = [URLManager requestURLGenerateWithURL:URLString];
    URLString = [URLString stringByRemovingPercentEncoding];
    
    if (!fileName) {
        fileName = [NSString stringWithFormat:@"uploadDefaultImage%@.jpg",[dict valueForKey:@"timestamp"]];
    }
    if (!name) {
        name = @"image";
    }
    if (!mimeType) {
        mimeType = @"image/jpeg";
    }
    
    AFHTTPSessionManager *httpManager = [AFHTTPSessionManager manager];
    httpManager.responseSerializer = [AFHTTPResponseSerializer serializer];
    httpManager.requestSerializer.timeoutInterval = 60;
//    httpManager.responseSerializer.acceptableContentTypes = [httpManager.responseSerializer.acceptableContentTypes setByAddingObject:@""];
    [httpManager POST:URLString parameters:dict constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        
        [formData appendPartWithFileData:imageData name:@"image" fileName:fileName mimeType:mimeType];
        
        NSLog(@">>>>> path: %@\nparam:%@\nname:%@\nfileName:%@\nmimeType:%@", URLString, dict, name, fileName, mimeType);
        
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
        progress1(uploadProgress);
//        NSLog(@"大小 = %lld,当前 = %lld",uploadProgress.totalUnitCount,uploadProgress.completedUnitCount);
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSError *jsonError;
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:&jsonError];
        
        if (jsonError) {
            
            NSLog(@"转码失败 jsonError = %@",jsonError);
            success(@{@"data":@""});
            
        }else {
            NSLog(@"result = %@ >>>>>> %@",result,@"上传成功");
            success(result);
        }
                
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"error = %@",error);
        failure(error);
    }];
}


//加密部分
- (NSString *) signStringOfParam:(NSDictionary *)param withMethod:(NSString *)method withUrlString:(NSString *)urlstring
{
    NSArray *keys = param.allKeys;
    
    NSArray *sortedArray = [keys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    NSMutableString *mStr = [NSMutableString string];
    
    [mStr appendString:method.uppercaseString];
    [mStr appendString:@" "];
    [mStr appendString:urlstring];
    [mStr appendString:@"?"];
    
    for(NSString *key in sortedArray){
        NSString *value = [param objectForKey:key];
        NSString *string = [NSString stringWithFormat:@"%@=%@",key,value];
        [mStr appendString:string];
        if([sortedArray indexOfObject:key] != sortedArray.count - 1){
            [mStr appendString:@"&"];
        }
    }

    NSString *uppercaseString = mStr;
    
    NSLog(@"**********%@^^^^^^^%@",uppercaseString,[[uppercaseString md5] uppercaseString]);
    return [[uppercaseString md5] uppercaseString];
}

/*
 GET /v1/video/templates?is_charge=0&key=WFkHndoRTcEQS8gXrp&length=4&page=1&short=0&style_id=1&timestamp=1490978158&token=123123^^^^^^^ADE8B40C773DE3142427448195F4EE96
    
 "GET \/v1\/video\/templates?is_charge=0&key=WFkHndoRTcEQS8gXrp&length=4&page=1&short=0&style_id=1&timestamp=1490978158&token=123123"
 
 */

- (NSMutableDictionary *) paramerOfSign:(NSDictionary *)dic withMethod:(NSString *)method withUrlString:(NSString *)urlstring
{
    NSMutableDictionary * parmer = [NSMutableDictionary dictionary];
    [parmer addEntriesFromDictionary:dic];
    [parmer setObject:[self signStringOfParam:parmer withMethod:method withUrlString:urlstring] forKey:@"sign"];
    [parmer removeObjectForKey:@"key"];
    return parmer;
}


@end
