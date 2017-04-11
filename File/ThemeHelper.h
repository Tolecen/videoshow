//
//  ThemeHelper.h
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoTheme.h"

/** 主题版本 */
#define THEME_CURRENT_VERSION @"theme_current_version"
/** 作者 */
#define THEME_VIDEO_AUTHOR @"theme_author.png"
/** 秒拍主题公共包 */
#define THEME_VIDEO_COMMON @"Common"
/** 内置MV主题 */
#define THEME_MUSIC_VIDEO_ASSETS @"MusicVideoAssets"
/** 下载MV主题 */
#define THEME_DOWNLOAD_VIDEO @"Download"
/** 空主题 */
#define THEME_EMPTY @"Empty"
/** 内置滤镜 */
#define THEME_FILTER_ASSETS @"FilterAssets"
/** 内置音乐 */
#define THEME_MUSIC_ASSETS @"MusicAssets"



// THEME_MUSIC_ASSETS MusicAssets.zip-->
// THEME_EMPTY Empty.zip-->
// THEME_VIDEO_COMMON Common.zip-->
// THEME_FILTER_ASSETS FilterAssets.zip-->
// THEME_MUSIC_VIDEO_ASSETS MusicVideoAssets.zip-->

#define theme_version [NSArray arrayWithObjects:@"0", @"0", @"2", @"2", @"2", nil]

#define themesIn [NSArray arrayWithObjects:@"Genius", @"GrowUp", @"Friends", @"Spaceship", @"HelloKitty", @"Christmas", nil]

#define filterIn [NSArray arrayWithObjects:@"Empty", @"Baixi", @"1974", @"Chenxi", @"Nvwang", @"Luosu", @"Nuanmeng", @"Huahuo", @"Satuo", @"Youjing", @"Yuanjing", nil]

@interface ThemeHelper : NSObject

+ (instancetype)helper;

/**
 *  把app中的zip文件copy到手机中，并解压，如果Theme版本号（@theme_version）改变的话，则删除以前的，并重新解压
 *
 *  @return 一个theme的路径
 */
- (NSString *)prepareTheme;

/**
 *  生成本地的VideoTheme
 *
 *  @param themeName         名字
 *  @param themeDisplayName  显示名字
 *  @param themeIconResource 图标的名字
 *
 *  @return 一个VideoTheme
 */
- (VideoTheme *)loadThemeRes:(NSString *)themeName themeDisplayName:(NSString *)themeDisplayName themeIconResource:(NSString *)themeIconResource;

/**
 *  处理下载的zip文件
 *
 *  @param zipFileDir zip文件地址
 */
- (void)parseThemeDownload:(NSString *)zipFileDir;

/**
 *  处理theme的音频
 *
 *  @param themeDir theme路径
 *  @param theme    theme名称
 */
- (void)prepareMusicPath:(NSString *)themeDir VideoTheme:(VideoTheme *)theme;

/**
 *  处理一个Theme路径下的特效
 *
 *  @param themePath 绝对路径
 *
 *  @return 一个VideoTheme
 */
- (VideoTheme *)loadThemeJson:(NSString *)themePath;

/**
 *  处理一个大主题下的所有Theme
 *
 *  @param type       主题名字，如 MusicVideoAssets
 *  @param themeNames 主题下，Theme的名字
 *
 *  @return VideoTheme的集合
 */
- (NSMutableArray *)parseTheme:(NSString *)type themeNames:(NSArray *)themeNames;

@end
