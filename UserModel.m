//
//  UserModel.m
//  videoshow
//
//  Created by gutou on 2017/3/24.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+ (NSDictionary *) pathsByPropertyKey
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super pathsByPropertyKey]];
    [dic addEntriesFromDictionary:@{@"ad_id":@"id"}];
    return dic;
}

//请求启动动画
+ (void) requestAdSplashDataWithSuccessHandle:(SuccessHandle)SuccessHandle
                                FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringSplash
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                            
                                               NSError *error;
                                               UserModel *model = [MTLJSONAdapter modelOfClass:[UserModel class] fromJSONDictionary:responseObject[@"data"] error:&error];
                                               
                                               NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                                               [dict setValue:model.ad_id forKey:@"ad_id"];
                                               [dict setValue:model.platform forKey:@"platform"];
                                               [dict setValue:model.image_url forKey:@"image_url"];
                                               [dict setValue:model.duration forKey:@"duration"];
                                               [dict setValue:model.link forKey:@"link"];
                                               
                                               if (!error) {
                                                  SuccessHandle(dict);
                                               }                                               
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}

//请求轮播图
+ (void) requestBannersWithSuccessHandle:(SuccessHandle)SuccessHandle
                           FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringBanners
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               SuccessHandle(responseObject[@"data"]);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}


//用户基本信息
+ (void) requestUserInfoWithSuccessHandle:(SuccessHandle)SuccessHandle
                            FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringUserInfo
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               UserModel *model = [MTLJSONAdapter modelOfClass:[UserModel class] fromJSONDictionary:responseObject[@"data"] error:nil];
                                               
                                               SuccessHandle(model);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}

@end
