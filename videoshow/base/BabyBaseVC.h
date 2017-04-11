//
//  BabyBaseVC.h
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "MacroDefinition.h"


@interface BabyBaseVC : UIViewController

- (void)sharePin:(Pin *)pin;
- (void)shareUser:(UserInfoNoPin *)user;

- (void)shareCommon:(NSString *)shareTitle shareDes:(NSString *)shareDes shareUrl:(NSString *)shareUrl shareImageUrl:(NSString *)shareImageUrl shareImage:(UIImage *)shareImage;

- (void)loginUser;
- (void)loginSina;
- (void)loginQq;

- (void)initUserInfo;

/**
 *  举报pin
 */
- (void)shareReport;
/**
 *  删除pin
 */
- (void)shareDelete;

- (void)pinLikePost:(Pin *)pin withLike:(NSString *)like;

- (void)uploadPin;

- (void)uploaPinNotification:(NSNotification*)notification;

- (void)startNetworkReachability;
- (void)stopNetworkReachability;

@property(nonatomic, assign)bool isLogin;
@property(nonatomic, assign)long loginUserId;
@property(nonatomic, strong)UserInfomation *loginUserInfomation;
@property(nonatomic, assign)BOOL isNetworkWAN;

@end
