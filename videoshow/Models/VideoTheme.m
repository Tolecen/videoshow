//
//  VideoTheme.m
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoTheme.h"

@implementation VideoTheme

+ (instancetype)initWithJsonDic:(NSDictionary *)dic
{
    VideoTheme *theme = [[self alloc]init];
    theme.themeName = [[dic valueForKey:@"themeName"] stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    theme.themeDisplayName = [dic valueForKey:@"themeDisplayName"];
    theme.isEmpty = [dic valueForKey:@"isEmpty"];
    theme.isMP4 = [dic valueForKey:@"isMP4"];
    theme.isFilter = [dic valueForKey:@"isFilter"];
    theme.isMv = [dic valueForKey:@"isMV"];
    if (theme.isMv) {
        theme.musicName = [dic valueForKey:@"musicName"];
        theme.musicTitle = [dic valueForKey:@"musicTitle"];
        if (theme.musicTitle == nil || theme.musicTitle.length == 0) {
            theme.musicTitle = [theme.themeName stringByReplacingOccurrencesOfString:@"_" withString:@" "];
        }
    }
    
    if (theme.isMP4)
        theme.fileExt = @"mp4";
    
    return theme;
}

+ (instancetype)initWithThemeName:(NSString *)themeName themeDisplayName:(NSString *)themeDisplayName themeIconResource:(NSString *)themeIconResource
{
    VideoTheme *theme = [[self alloc]init];
    theme.themeName = themeName;
    theme.themeDisplayName = themeDisplayName;
    theme.themeIconResource = themeIconResource;
    
    return theme;
}

@end
