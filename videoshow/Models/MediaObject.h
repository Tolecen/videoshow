//
//  MediaObject.h
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MediaPart.h"

/** 拍摄 */
#define MEDIA_PART_TYPE_RECORD 0
/** 导入视频 */
#define MEDIA_PART_TYPE_IMPORT_VIDEO 1
/** 导入图片 */
#define MEDIA_PART_TYPE_IMPORT_IMAGE 2
/** 使用系统拍摄mp4 */
#define MEDIA_PART_TYPE_RECORD_MP4 3
/** 默认最大时长 */
#define DEFAULT_MAX_DURATION 10 * 1000
/** 默认最小时长 */
#define DEFAULT_MIN_DURATION 3 * 1000
/** 默认码率 */
#define DEFAULT_VIDEO_BITRATE 1500

@interface MediaObject : NSObject

/** 视频最大时长，默认10秒 */
@property(nonatomic, assign) int mMaxDuration;
/** 视频最小时长，默认3秒 */
@property(nonatomic, assign) int mMinDuration;
/** 视频目录 */
@property(nonatomic, strong) NSString *mOutputDirectory;
/** 对象文件 */
@property(nonatomic, strong) NSString *mOutputObjectPath;
/** 视频码率 */
@property(nonatomic, assign) int mVideoBitrate;
/** 最终视频输出路径 */
@property(nonatomic, strong) NSString *mOutputVideoPath;
/** 最终视频截图输出路径 */
@property(nonatomic, strong) NSString *mOutputVideoThumbPath;
/** 文件夹、文件名 */
@property(nonatomic, strong) NSString *mKey;
/** 当前分块 */
@property(nonatomic, strong) MediaPart *mCurrentPart;
/** 是否在录制中 */
@property(nonatomic, assign) BOOL isRecording;
/** 获取所有分块 */
@property(nonatomic, strong) NSMutableArray *mMediaList;

+ (instancetype)initWithKey:(NSString *)key path:(NSString *)path;

/** 获取视频临时输出播放 */
- (NSString *)getOutputTempVideoPath;

/** 获取视频信息存储路径 */
- (NSString *)getObjectFilePath;

/** 获取录制的总时长- 实时 */
- (int)getDuration;

/** 获取录制的总时长 */
- (int)getRealDuration;

/** 删除分块 */
- (void)removePart:(MediaPart *)part deleteData:(BOOL)deleteData;

/**
 *  生成分块信息，主要用于拍摄
 *
 *  @param cameraId 记录摄像头是前置还是后置
 *
 *  @return 分块信息
 */
- (MediaPart *)buildMediaPart:(int)cameraId;

/**
 *  生成分块信息，主要用于拍摄
 *
 *  @param cameraId    记录摄像头是前置还是后置
 *  @param videoSuffix 视频后缀名
 *
 *  @return 分块信息
 */
- (MediaPart *)buildMediaPart:(int)cameraId videoSuffix:(NSString *)videoSuffix;

/**
 *  生成分块信息，主要用于视频导入
 *
 *  @param path     存放导入的视频路径
 *  @param duration 总时长
 *  @param type     分块类别
 *
 *  @return 分块信息
 */
- (MediaPart *)buildMediaPart:(NSString *)path duration:(int)duration type:(int)type;

/**
 *  生成分块信息，主要用于图片导入
 *
 *  @param path      存放导入的视频路径
 *  @param duration  总时长
 *  @param type      分块类别
 *  @param tempCount 图片数量
 *
 *  @return 分块信息
 */
- (MediaPart *)buildMediaPart:(NSString *)path duration:(int)duration type:(int)type tempCount:(int)tempCount;

/**
 *  获取分块视频的集合
 *
 *  @return NSString 集合
 */
- (NSMutableArray *)getConcatYUVArrayMediaPath;

/**
 *  获取ffmpeg合并视频时的字符串
 *
 *  @return 视频合集的字符串
 */
- (NSString *)getConcatYUV;

/**
 *  获取当前分块
 *
 *  @return 当前分块
 */
- (MediaPart *)getCurrentPart;

/**
 *  获取当前分块的index
 *
 *  @return index
 */
- (int)getCurrentIndex;

/**
 *  获取第几个分块
 *
 *  @param index 分块位置
 *
 *  @return 分块信息
 */
- (MediaPart *)getPart:(int)index;

/**
 *  删除这个object 并删除文件
 */
- (void)deleteObject;

@end
