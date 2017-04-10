//
//  BasePayController.m
//  videoshow
//
//  Created by gutou on 2017/3/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BasePayController.h"
#import "WXApiManager.h"

@interface BasePayController ()

@end

@implementation BasePayController

+ (instancetype) shareInstance;
{
    static BasePayController *sharedClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[BasePayController alloc] init];
    });
    return sharedClient;
}


- (void) AlipayProductWithMoney:(NSString *)money orderID:(NSString *)orderID;
{

}

/** 商家向财付通申请的商家id */
/** 预支付订单 */
- (void) WXpayProductWithOpenID:(NSString *)openID
                    merchantsId:(NSString *)partnerId
                        orderId:(NSString *)prepayId
                       nonceStr:(NSString *)nonceStr
                      timeStamp:(UInt32)timeStamp
                        package:(NSString *)package
                           sign:(NSString *)sign;
{
    [WXApi registerApp:openID];
    
    //调起微信支付
    PayReq *req             = [[PayReq alloc] init];
    req.partnerId           = partnerId;
    req.prepayId            = prepayId;
    req.nonceStr            = nonceStr;
    req.timeStamp           = timeStamp;
    req.package             = package;
    req.sign                = sign;
    req.openID              = openID;
    [WXApiManager sendRequest:req];
}


@end
