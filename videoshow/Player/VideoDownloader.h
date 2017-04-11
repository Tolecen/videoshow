//
//  VideoDownloader.h
//  Babypai
//
//  Created by ning on 15/8/2.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DownloadCompletionBlock)(NSString* data, NSString* errorString);

typedef void (^DownloadProgressBlock)(float progress);

@interface VideoDownloader : NSObject
{
    NSString *diskCachePath; //物理缓存路径
}

+ (VideoDownloader *)videoDownloader;

/**
 *  下载文件
 *
 *  @param videoPath       视频地址
 *  @param completionBlock 回调
 */
- (void)downloadVideo:(NSString *) videoPath completion:(DownloadCompletionBlock)completionBlock progress:(DownloadProgressBlock)progressBlock;

@end
