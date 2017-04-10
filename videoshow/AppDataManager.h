//
//  AppDataManager.h
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>


extern NSString * const appDidLogoutNotification;
extern NSString * const appDidLoginNotification;


//存储本地化的数据
@interface AppDataManager : NSObject


+(instancetype)defaultManager;

@property (readonly, nonatomic, copy) NSString     * identifier;//登陆id标识
- (void) setIdentifier:(NSString *)identifier;

/**
 *  和identifier相同
 */
@property (readonly, nonatomic, copy) NSString     * userId;//用户id
@property (readonly, nonatomic, copy) NSString     * phoneNumber;//用户手机号
@property (readonly, nonatomic, copy) NSString     * user_vip;//会员标识
@property (readonly, nonatomic, copy) NSString     * name;//用户名称
@property (readonly, nonatomic, copy) NSString     * payPassWord;//支付密码
@property (readonly, nonatomic, copy) NSString     * moneyCount;//账户余额
@property (readonly, nonatomic, copy) NSString     * device_token;//本地设备号
@property (readonly, nonatomic, strong) NSData     * user_image;//用户头像
- (void) setUserId:(NSString *)userId;
- (void) setPhoneNumber:(NSString *)phoneNumber;
- (void) setUser_vip:(NSString *)user_vip;
- (void) setName:(NSString *)name;
- (void) setPayPassWord:(NSString *)payPassWord;
- (void) setMoneyCount:(NSString *)moneyCount;
- (void) setDevice_token:(NSString *)device_token;
- (void) setUser_image:(NSData *)user_image;

@property (readonly, nonatomic, copy) NSString *publicData;//公共属性
- (void) setPublicData:(NSString *)publicData;
@property (readonly, nonatomic, strong) NSDictionary *adDic;//启动动画内容
- (void) setAdDic:(NSDictionary *)adDic;

/**
 *  是否登陆
 */
- (BOOL) hasLogin;

/**
 *  是否会员
 */
- (BOOL) hasVip;

//注销
- (void) logout;

//登陆设置id
-(void)loginWithIdentifier:(NSString *)identifier;


@end
