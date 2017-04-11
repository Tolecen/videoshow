//
//  VideoEncoder.h
//  FFmpegTest01
//
//  Created by ning on 15/10/9.
//  Copyright (c) 2015年 asdd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VideoEncoder : NSObject

typedef void (^OnEncoderProgressBlock)(long size, long timestamp);
typedef void (^OnEncoderCompletionBlock)(int ret, NSString* retString);

+ (VideoEncoder *)videoEncoder;

- (void) videoMerge:(NSArray *)argvArray progress:(OnEncoderProgressBlock)progressBlock completion:(OnEncoderCompletionBlock)completionBlock;
- (void) videoMerge:(int)argc withArgv:(char **)argv progress:(OnEncoderProgressBlock)progressBlock completion:(OnEncoderCompletionBlock)completionBlock;
- (int) videoProgress:(int)videoTotalTime;
- (int) videoFinish;

@end
