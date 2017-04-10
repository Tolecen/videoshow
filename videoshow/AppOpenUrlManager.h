//
//  AppOpenUrlManager.h
//  videoshow
//
//  Created by gutou on 2017/3/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CallURLMode) {
    CallURL_Baidu_Map = 0,//百度地图app
    CallURL_Gaode_Map,//高德地图app
    CallURL_Google_Map,//谷歌地图app
    CallURL_Apple_Map,//苹果自带的地图
    CallURL_WeiXin_Social,//微信
    CallURL_QQ_Social,//qq
    CallURL_Sina_Social,//新浪
};

@interface AppOpenUrlManager : NSObject

+ (instancetype)shareInstance;

- (BOOL) isCanOpenUrlWithCallURLMode:(CallURLMode)url;

@end
