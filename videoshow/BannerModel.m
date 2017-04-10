//
//  BannerModel.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BannerModel.h"

@implementation BannerModel

+ (NSDictionary *) pathsByPropertyKey
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super pathsByPropertyKey]];
    [dic addEntriesFromDictionary:@{@"ad_id":@"id"}];
    return dic;
}

+ (void)requestBannerModelOfCompletionHandler:(SuccessHandle)successHandler
                                  failHandler:(FailureHandle)failHandler;
{
    NSDictionary *paramer = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET URLString:kURLStringFocus parameters:paramer successHandle:^(id responseObject) {
        
        NSArray *dataArr = [MTLJSONAdapter modelsOfClass:[BannerModel class] fromJSONArray:responseObject[@"data"] error:nil];
        successHandler(dataArr);
    } failureHandle:^(NSError *error) {
        failHandler(error);
    }];
}

@end
