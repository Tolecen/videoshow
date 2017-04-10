//
//  UserModel.h
//  videoshow
//
//  Created by gutou on 2017/3/24.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseModel.h"

@interface UserModel : BaseModel


@property (nonatomic, copy) NSString *ad_id;//
@property (nonatomic, copy) NSString *platform;//
@property (nonatomic, copy) NSString *image_url;//
@property (nonatomic, strong) NSData *image_data;
@property (nonatomic, copy) NSString *duration;//
@property (nonatomic, copy) NSString *link;//

//请求启动动画
+ (void) requestAdSplashDataWithSuccessHandle:(SuccessHandle)SuccessHandle
                                FailureHandle:(FailureHandle)FailureHandle;

//请求轮播图
+ (void) requestBannersWithSuccessHandle:(SuccessHandle)SuccessHandle
                           FailureHandle:(FailureHandle)FailureHandle;


/*
 用户id
 昵称
 性别
 头像
 金币
 是否为vip会员
 number 上传模版数
 number 收藏数
 number 作品数
 */
@property (nonatomic, copy) NSString *user_id;//
@property (nonatomic, copy) NSString *nickname;//
@property (nonatomic, copy) NSString *gender;//
@property (nonatomic, copy) NSString *avatar;//
@property (nonatomic, copy) NSString *user_gold;//
@property (nonatomic, copy) NSString *is_vip;//
@property (nonatomic, strong) NSNumber *templates;//
@property (nonatomic, strong) NSNumber *collections;//
@property (nonatomic, strong) NSNumber *works;//

//用户基本信息
+ (void) requestUserInfoWithSuccessHandle:(SuccessHandle)SuccessHandle
                            FailureHandle:(FailureHandle)FailureHandle;

@end
