//
//  VideoEncoder.m
//  FFmpegTest01
//
//  Created by ning on 15/10/9.
//  Copyright (c) 2015年 asdd. All rights reserved.
//

#import "VideoEncoder.h"

#import "ffmpeg_encoder.h"


@implementation VideoEncoder

+ (VideoEncoder *)videoEncoder
{
    static dispatch_once_t onceToken;
    static VideoEncoder *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[VideoEncoder alloc]init];
    });
    return instance;
}

- (void) videoMerge:(NSArray *)argvArray progress:(OnEncoderProgressBlock)progressBlock completion:(OnEncoderCompletionBlock)completionBlock
{
    int argc = (int)argvArray.count;
    char *argv[argc];
    
    for (int i = 0; i < argc ; i++) {
        
//        char *argv_char = [[_aFilters objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding];
        
        char *argv_char = (char *)[[argvArray objectAtIndex:i] cStringUsingEncoding:NSASCIIStringEncoding];
        //        sscanf([[arr objectAtIndex:i] UTF8String], "%x", &mCode);
        NSLog(@"char is %s in %d", argv_char, i);
        argv[i] = argv_char;
    }
    
    EncoderProgressBlock progress = ^(long total_size, long pts) {
        progressBlock(total_size, pts);
    };
    
    EncoderCompletionBlock completion = ^(int ret, char* retString){
        completionBlock(ret, [NSString stringWithFormat:@"%s", retString]);
    };
    
    int ret = video_merge(argc, argv, progress, completion);
    NSLog(@"encoder finish : :%d argv=%s", ret,argv);
    
    
}

- (void) videoMerge:(int)argc withArgv:(char **)argv progress:(OnEncoderProgressBlock)progressBlock completion:(OnEncoderCompletionBlock)completionBlock
{
    
    EncoderProgressBlock progress = ^(long total_size, long pts) {
        progressBlock(total_size, pts);
    };
    
    EncoderCompletionBlock completion = ^(int ret, char* retString){
        completionBlock(ret, [NSString stringWithFormat:@"%s", retString]);
    };
    
    int ret = video_merge(argc, argv, progress, completion);
    NSLog(@"encoder finish : %d", ret);
}
- (int) videoProgress:(int)videoTotalTime
{
    
    return video_progress(videoTotalTime);
}
- (int) videoFinish
{
    
    return video_finish();
}


@end
