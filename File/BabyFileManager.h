//
//  BabyFileManager.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//http://www.superqq.com/blog/2015/07/24/nsfilemanagerwen-jian-cao-zuo-de-shi-ge-xiao-gong-neng/

#import <Foundation/Foundation.h>
#import "MediaObject.h"
#import "BabyUploadEntity.h"
#import "MacroDefinition.h"

#define VIDEO_FOLDER @"videos"

typedef void (^OnDeleteCompletionBlock)(BOOL contextDidSave);

@interface BabyFileManager : NSObject

+ (instancetype)manager;

- (void)deleteFile:(NSString *)filePath;

- (void)deleteUploadEntity:(BabyUploadEntity *)uploadEntity withCompletion:(OnDeleteCompletionBlock)completionBlock;

/**
 *  获取当前Document路径
 *
 *  @return 路径
 */
- (NSString *)getCurrentDocumentPath;

/**
 *  获取Theme所在的文件夹
 *
 *  @return 文件夹路径
 */
- (NSString *)themeDir;

/**
 *  更新保存用户昵称（png）
 *
 *  @param image uiimage
 *
 *  @return 保存位置
 */
- (NSString *)updateVideoAuthorLogo:(UIImage *)image;

/**
 *  保存图片（jpg）
 *
 *  @param filePath 保存位置
 *  @param image    uiimage
 *
 *  @return 保存位置
 */
- (NSString *)saveUIImageToPath:(NSString *)filePath withImage:(UIImage *)image;


- (void) removeFile:(NSURL *)outputFileURL;
- (void) copyFileToDocuments:(NSURL *)fileURL;
- (void) copyFileToCameraRoll:(NSURL *)fileURL;

+ (NSString *)createVideoFolderIfNotExist:(NSString *)key;
+ (NSString *)createFolderIfNotExist:(NSString *)key;
+ (NSURL *)getVideoSaveFilePathString;
+ (NSString *)getVideoSaveFilePathString2;
/**
 *  创建ffmpeg使用的concat.txt文件
 *
 *  @param folderPath 文件位置
 *  @param concatText 文件内容
 *
 *  @return 文件路径
 */
+ (NSString *)getVideoMergeFilePathString:(NSString *)folderPath concatText:(NSString *)concatText;
+ (NSString *)getVideoSaveFolderPathString;

+ (NSString *)saveStringToFile:(NSString *)filePath concatText:(NSString *)concatText;

/**
 *  转化mediaobject的绝对路径为相对路径
 *
 *  @param mediaObjec 当前有绝对路径的
 *
 *  @return 相对路径的
 */
- (MediaObject *)convertMediaObject:(MediaObject *)mediaObjec;
- (MediaObject *)convertBackMediaObject:(MediaObject *)mediaObjec;

/**
 *  获取视频旋转信息
 *
 *  @param url 视频url
 *
 *  @return 视频旋转角度
 */
- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url;

/**
 *  格式化截取视频时间戳
 *
 *  @param time 时间戳
 *
 *  @return HH:mm:ss
 */
- (NSString *)convertVideoCutTime:(long)time;

/**
 *  计算剩余磁盘空间
 *
 *  @return 磁盘空间
 */
- (uint64_t)freeDiskSpace;

@end
