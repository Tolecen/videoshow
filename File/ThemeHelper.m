//
//  ThemeHelper.m
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "ThemeHelper.h"
#import "SSZipArchive.h"
#import "StringUtils.h"
#import "BabyFileManager.h"

@implementation ThemeHelper

+ (instancetype)helper
{
    static ThemeHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[self alloc] init];
    });
    return helper;
}

- (NSString *)prepareTheme
{
    NSArray *assets = [NSArray arrayWithObjects:THEME_MUSIC_ASSETS, THEME_EMPTY, THEME_VIDEO_COMMON, THEME_FILTER_ASSETS, THEME_MUSIC_VIDEO_ASSETS, nil];
    NSFileManager *file_manager = [NSFileManager defaultManager];
    
    NSString *mThemeCacheDir = [[BabyFileManager manager] themeDir];
    
    for (int i = 0; i < assets.count; i ++) {
        
        NSString *name = [assets objectAtIndex:i];
        
        NSString *resource = [mThemeCacheDir stringByAppendingPathComponent:name];
        
        BOOL isFileDir;
        if ([file_manager fileExistsAtPath:resource]) {
            if ([file_manager fileExistsAtPath:resource isDirectory:&isFileDir] && !isFileDir) {
                continue;
            }
            
            if ([[theme_version objectAtIndex:i] intValue] > [[Utils getUserDefaultStringWithName:[NSString stringWithFormat:@"%@_%@", THEME_CURRENT_VERSION, name]] intValue]) {
                [file_manager removeItemAtPath:resource error:nil];
            } else if (isFileDir && [file_manager subpathsAtPath:resource].count > 0) {
                continue;
            }
            
        }
        
        if ([name hasSuffix:@".png"]) {
            NSString *filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:name];
            [file_manager copyItemAtPath:filePathFromApp toPath:resource error:nil];
        } else {
            
            NSString *resourceZip = [mThemeCacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.zip", name]];
            
            NSString *filePathFromApp = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[resourceZip lastPathComponent]];
            
            if ([file_manager copyItemAtPath:filePathFromApp toPath:resourceZip error:nil]) {
                
                [SSZipArchive unzipFileAtPath:resourceZip toDestination: mThemeCacheDir];
                
                [file_manager removeItemAtPath:resourceZip error:nil];
                [Utils setUserDefault:[theme_version objectAtIndex:i] nameWith:[NSString stringWithFormat:@"%@_%@", THEME_CURRENT_VERSION, name]];
                
            }
        }
        
}
    
    NSString *resourceDir = [mThemeCacheDir stringByAppendingPathComponent:THEME_MUSIC_VIDEO_ASSETS];
    if ([file_manager fileExistsAtPath:resourceDir]) {
        return resourceDir;
    }
    
    return nil;
}

- (VideoTheme *)loadThemeRes:(NSString *)themeName themeDisplayName:(NSString *)themeDisplayName themeIconResource:(NSString *)themeIconResource
{
    VideoTheme *theme = [VideoTheme initWithThemeName:themeName themeDisplayName:themeDisplayName themeIconResource:themeIconResource];
    return theme;
}

- (void)parseThemeDownload:(NSString *)zipFileDir
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:zipFileDir]) {
        NSString *fileDir = [zipFileDir stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"/%@", [zipFileDir lastPathComponent]] withString:@""];
        
        [SSZipArchive unzipFileAtPath:zipFileDir toDestination: fileDir];
        [file_manager removeItemAtPath:[fileDir stringByAppendingPathComponent:@"__MACOSX"] error:nil];
        [file_manager removeItemAtPath:zipFileDir error:nil];
    }
}

- (void)prepareMusicPath:(NSString *)themeDir VideoTheme:(VideoTheme *)theme
{
    if (theme != nil && themeDir != nil && ![StringUtils isEmpty:theme.musicName]) {
        NSString *mp3Name = [NSString stringWithFormat:@"%@.mp3", theme.musicName];
        NSString *mp3Dir = [themeDir stringByAppendingPathComponent:mp3Name];
        NSFileManager *file_manager = [NSFileManager defaultManager];
        if ([file_manager fileExistsAtPath:mp3Dir]) {
            theme.musicPath = mp3Dir;
        }
    }
}

- (VideoTheme *)loadThemeJson:(NSString *)themePath
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    
    NSString *themeFile = [themePath lastPathComponent];
    
    NSString *jsonPath = [themePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.json",themeFile]];
    if ([file_manager fileExistsAtPath:jsonPath]) {
        NSString * jsonString = [NSString stringWithContentsOfFile:jsonPath encoding:NSUTF8StringEncoding error:nil];
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
        
        VideoTheme *theme = [VideoTheme initWithJsonDic:jsonData];
        
        theme.themeFolder = themePath;
        
        [self prepareMusicPath:themePath VideoTheme:theme];
        
        NSString *iconFile = [themePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",themeFile]];
        
        if ([file_manager fileExistsAtPath:iconFile]) {
            theme.themeIcon = iconFile;
        } else {
            iconFile = [themePath stringByAppendingPathComponent:[NSString stringWithFormat:@"icon-%@@2x.png",themeFile]];
            if ([file_manager fileExistsAtPath:iconFile]) {
                theme.themeIcon = iconFile;
            }
        }
        return theme;
        
    }
    
    return nil;
}

- (NSMutableArray *)parseTheme:(NSString *)type themeNames:(NSArray *)themeNames
{
    NSMutableArray *result = [[NSMutableArray alloc]init];
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    
    NSString *mThemeCacheDir = [[BabyFileManager manager] themeDir];
    NSString *themePath = [mThemeCacheDir stringByAppendingPathComponent:type];
    
    if ([file_manager fileExistsAtPath:themePath]) {
        
        
        NSMutableArray *dirArray = [[NSMutableArray alloc] init];
        
        if (themeNames != nil) {
            BOOL isDir = NO;
            for (NSString *folder in themeNames) {
                NSString *path = [themePath stringByAppendingPathComponent:folder];
                [file_manager fileExistsAtPath:path isDirectory:(&isDir)];
                if (isDir && ![folder isEqualToString:@"__MACOSX"]) {
                    [dirArray addObject:path];
                }
                isDir = NO;
            }
        }
        
        if (dirArray.count == 0) {
            
            NSArray *fileList = [[NSArray alloc] init];
            //fileList便是包含有该文件夹下所有文件的文件名及文件夹名的数组
            fileList = [file_manager contentsOfDirectoryAtPath:themePath error:nil];
            
            //以下这段代码则可以列出给定一个文件夹里的所有子文件夹名
            BOOL isDir = NO;
            //在上面那段程序中获得的fileList中列出文件夹名
            for (NSString *file in fileList) {
                NSString *path = [themePath stringByAppendingPathComponent:file];
                [file_manager fileExistsAtPath:path isDirectory:(&isDir)];
                if (isDir && ![file isEqualToString:@"__MACOSX"]) {
                    [dirArray addObject:path];
                }
                isDir = NO;
            }
            
        }
        
        for (NSString *themeFolder in dirArray) {
            VideoTheme *theme = [self loadThemeJson:themeFolder];
            [result addObject:theme];
        }
        return result;
    }
    
    return nil;
}

@end
