 

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "AFURLSessionManager.h"


typedef void(^SuccessHandle)(id responseObject);

typedef void(^FailureHandle)(NSError * error);

typedef void(^ProgressHandle)(NSProgress *progress);

typedef NS_ENUM(NSUInteger ,HTTP_Method)
{
    POST = 0,
    GET,
    PUT,
    DELETE
};

@interface AppRequestSender : NSObject

+ (AppRequestSender *) shareRequestSender;

- (void) requestMethod:(HTTP_Method)method
             URLString:(NSString *)URLString
            parameters:(NSDictionary *)parameters
         successHandle:(SuccessHandle)success
         failureHandle:(FailureHandle)failure;

- (void) uploadFileWithURLString:(NSString *)URLString
                      parameters:(NSDictionary *)parameters
                       ImageData:(NSData *)imageData
                        fileName:(NSString *)fileName
                            name:(NSString *)name
                        mimeType:(NSString *)mimeType
                   successHandle:(SuccessHandle)success
                   failureHandle:(FailureHandle)failure
                  progressHandle:(ProgressHandle)progress1;

@end
