//
//  LoginModel.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "LoginModel.h"

@implementation LoginModel

+ (void) loginWithCode:(NSString *)code
         SuccessHandle:(SuccessHandle)SuccessHandle
         FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{@"code":code};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET URLString:kURLStringWxlogin
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                                   if (responseObject[@"data"]) {
                                                       
                                                       LoginModel *model = [MTLJSONAdapter modelOfClass:[LoginModel class] fromJSONDictionary:responseObject[@"data"] error:nil];
                                                       
                                                       [AppDataManager defaultManager].userId = model.user_id;
                                                       [AppDataManager defaultManager].identifier = model.token;
                                                   }
                                               SuccessHandle(responseObject);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}

+ (void) testGetLoginCodeWithSuccessHandle:(SuccessHandle)SuccessHandle
                             FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *parame = @{};
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringGetTestCode
                                              parameters:parame
                                           successHandle:^(id responseObject) {
                                               
                                               SuccessHandle(responseObject[@"data"]);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}

@end
