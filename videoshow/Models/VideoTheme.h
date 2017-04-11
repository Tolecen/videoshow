//
//  VideoTheme.h
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

#define THEME_STORE @"Store"
/** 主题商店 */
#define THEME_STORE_NAME @"更多MV"
/** 无主题 */
#define THEME_EMPTY @"Empty"

@interface VideoTheme : NSObject


/**
 * 主题图标
 */
@property(nonatomic, strong) NSString *themeIcon;

/**
 * 主题图标（主要用于内置主题、无主题）
 */
@property(nonatomic, strong) NSString *themeIconResource;

/** 
 * 主题文件夹
 */
@property(nonatomic, strong) NSString *themeFolder;

/**
 * 主题名称
 */
@property(nonatomic, strong) NSString *themeDisplayName;
/**
 * 主题文件夹名称
 */
@property(nonatomic, strong) NSString *themeName;
/**
 * 主题下载地址
 */
@property(nonatomic, strong) NSString *themeDownloadUrl;
/**
 * 主题更新时间
 */
@property(nonatomic, assign) long themeUpdateAt;
/**
 * 是否锁定
 */
@property(nonatomic, assign) bool isLock;
/**
 * 是否需要购买
 */
@property(nonatomic, assign) bool isBuy;
/**
 * 唯一编号
 */
@property(nonatomic, assign) long themeId;
/**
 * 主题角标： 0是没有，1是最新，2是最热
 */
@property(nonatomic, assign) int pic_type;
@property(nonatomic, strong) NSString *banner;
/**
 * 主题说明
 */
@property(nonatomic, strong) NSString *desc;
/**
 * 主题价格
 */
@property(nonatomic, assign) int price;
/**
 * 主题预览地址
 */
@property(nonatomic, strong) NSString *previewVideoPath;
/** 主题本地地址 */
@property(nonatomic, strong) NSString *themeUrl;
/**
 * 主题所属的二级分类，例如音乐下面的流行、摇滚
 */
@property(nonatomic, strong) NSString *category;
/**
 * 主题类型
 */
@property(nonatomic, assign) int themeType;
/**
 * 1、用户发布一条带主题的视频
 * 2、把APP 分享到朋友圈
 * 3、邀请好友一次
 * 0、是没有锁定条件的主题
 */
@property(nonatomic, assign) int lockType;

/**
 * 是否是MV效果主题
 */
@property(nonatomic, assign) bool isMv;
/** 是否是滤镜 */
@property(nonatomic, assign) bool isFilter;
/**
 * 是否是mp4类型
 */
@property(nonatomic, assign) bool isMP4;
/**
 * 是否是空主题
 */
@property(nonatomic, assign) bool isEmpty;

/** 文件后缀 */
@property(nonatomic, strong) NSString *fileExt;

/** 音乐名称 */
@property(nonatomic, strong) NSString *musicName;
/** 主题音乐名称 */
@property(nonatomic, strong) NSString *musicTitle;
/** 主题音乐路径 */
@property(nonatomic, strong) NSString *musicPath;

// ~~~~ 下面字段用于下载

/**
 * 下载状态
 */
@property(nonatomic, assign) int status;
/**
 * 下载进度
 */
@property(nonatomic, assign) float percent;

+ (instancetype)initWithJsonDic:(NSDictionary *)dic;

+ (instancetype)initWithThemeName:(NSString *)themeName themeDisplayName:(NSString *)themeDisplayName themeIconResource:(NSString *)themeIconResource;

@end
