//
//  URLManager.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "URLManager.h"


#ifdef DEBUG
NSString *const kBaseURL             = @"http://api.msxxapp.com";//

#else

NSString *const kBaseURL             = @"http://api.msxxapp.com";//

#endif


NSString *const kURLStringReg                       = @"";
NSString *const kURLStringWxlogin                   = @"/v1/user/wxlogin";//微信登陆
NSString *const kURLStringUserInfo                  = @"/v1/user/info";//个人信息
NSString *const kURLStringGetTestCode               = @"/v1/user/code";//请求是否允许游客登录

NSString *const kURLStringSplash                    = @"/v1/system/splash";//启动动画
NSString *const kURLStringBanners                   = @"/v1/system/banners";//广告横幅
NSString *const kURLStringFocus                     = @"/v1/system/focus";//轮播图

NSString *const kURLStringTemplates                 = @"/v1/video/templates";//视频列表
NSString *const kURLStringTemplate                  = @"/v1/video/template";//单个视频详情
NSString *const kURLStringTemplateStyles            = @"/v1/video/styles";//视频模板分类
NSString *const kURLStringTemplateUploadImage       = @"/v1/user/upload";//上传图片素材

NSString *const kURLStringMyCollectionList          = @"/v1/user/collections";//我的收藏列表
NSString *const kURLStringCollectionTemplate        = @"/v1/user/collection";//收藏模板功能 取消收藏

NSString *const kURLStringMyWatermarkList           = @"/v1/user/watermarks";//用户水印列表
NSString *const kURLStringWatermarkUploadOrDelete   = @"/v1/user/watermark";//用户水印上传 删除

NSString *const kURLStringMyWorkList                = @"/v1/user/works";//我的作品列表
NSString *const kURLStringMyWorkDetailOrDelete      = @"/v1/user/work";//我的作品详情 or 删除 合成任务上传

NSString *const kURLStringChargeTemplate            = @"/v1/charge/template";//购买模板 付费


@implementation URLManager

+ (NSString *)requestURLGenerateWithURL:(NSString *const) path{
    if ([path containsString:@"http://"]) {
        return path;
    }
    return [kBaseURL stringByAppendingString:path];
}

@end
