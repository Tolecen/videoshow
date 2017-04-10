//
//  URLManager.h
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 *  根地址
 */
extern NSString *const kBaseURL;


/**
 *  提交用户注册信息
 */
extern NSString *const kURLStringReg;


/**
 *  微信登陆
 */
extern NSString *const kURLStringWxlogin;


/**
 *  是否允许游客登录 return code=0 message=ok
 */
extern NSString *const kURLStringGetTestCode;


/**
 *  个人信息
 */
extern NSString *const kURLStringUserInfo;


/**
 *  启动动画
 */
extern NSString *const kURLStringSplash;


/**
 *  广告横幅
 */
extern NSString *const kURLStringBanners;


/**
 *  轮播图
 */
extern NSString *const kURLStringFocus;


/**
 *  视频列表
 */
extern NSString *const kURLStringTemplates;


/**
 *  单个视频详情
 */
extern NSString *const kURLStringTemplate;


/**
 *  视频模板分类
 */
extern NSString *const kURLStringTemplateStyles;


/**
 *  上传图片素材
 */
extern NSString *const kURLStringTemplateUploadImage;


/**
 *  我的收藏列表
 */
extern NSString *const kURLStringMyCollectionList;


/**
 *  收藏模板功能
 */
extern NSString *const kURLStringCollectionTemplate;


/**
 *  我的水印
 */
extern NSString *const kURLStringMyWatermarkList;


/**
 *  水印上传  or   删除
 */
extern NSString *const kURLStringWatermarkUploadOrDelete;


/**
 *  我的作品列表
 */
extern NSString *const kURLStringMyWorkList;


/**
 *  作品详情 or 删除
 */
extern NSString *const kURLStringMyWorkDetailOrDelete;


/**
 *  购买模板 付费
 */
extern NSString *const kURLStringChargeTemplate;


@interface URLManager : NSObject

+ (NSString *)requestURLGenerateWithURL:(NSString *const) path;

@end
