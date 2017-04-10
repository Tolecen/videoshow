//
//  BasePayController.h
//  videoshow
//
//  Created by gutou on 2017/3/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BasePayController : NSObject

+ (instancetype) shareInstance;

//微信支付
- (void) WXpayProductWithOpenID:(NSString *)openID
                    merchantsId:(NSString *)partnerId
                        orderId:(NSString *)prepayId
                       nonceStr:(NSString *)nonceStr
                      timeStamp:(UInt32)timeStamp
                        package:(NSString *)package
                           sign:(NSString *)sign;

//支付宝支付
- (void) AlipayProductWithMoney:(NSString *)money orderID:(NSString *)orderID;

@end
