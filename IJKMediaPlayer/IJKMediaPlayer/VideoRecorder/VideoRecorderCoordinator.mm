//
//  VideoRecorderCoordinator.m
//  IJKMediaPlayer
//
//  Created by ning on 16/4/30.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import "VideoRecorderCoordinator.h"
#import "VideoRecorder.hpp"


@implementation VideoRecorderCoordinator


- (void)setDelegate:(id<VideoRecorderCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue
{
    if(delegate && ( delegateCallbackQueue == NULL)){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
    }
    @synchronized(self)
    {
        _delegate = delegate;
        if (delegateCallbackQueue != _delegateCallbackQueue){
            _delegateCallbackQueue = delegateCallbackQueue;
        }
    }
}

- (void)coorInitRecorder:(NSString *)fileName srcHight:(int)srcHight cameraSelection:(int)cameraSelection andHuafuHeight:(int)huafuHeight audioBitrate:(long)audioBitrate videoBitrate:(long)videoBitrate hasAudio:(int)hasAudio andOverlayName:(NSString *)overlayName
{
    
    initRecorder((char*)[fileName UTF8String],srcHight,huafuHeight,cameraSelection, audioBitrate, videoBitrate, hasAudio,(char*)[overlayName UTF8String]);
    
    if ([self.delegate respondsToSelector:@selector(recorder:didFinishInit:)]) {
        [self.delegate recorder:self didFinishInit:nil];
    }
    
}

- (void)coorSetRecorderInfo:(int)srcHight cameraSelection:(int)cameraSelection
{
    setRecorderInfo(srcHight, cameraSelection);
}

- (void)coorRecordeVideo:(void *)frame timestamp:(long)timestamp
{
    recordeVideo(frame, timestamp);
}

- (void)coorRecordeAudio:(void *)samples numSamples:(long)numSamples
{
    recordeAudio(samples, numSamples);
}

- (void)coorRecordeClose
{
    recordeClose();
    if ([self.delegate respondsToSelector:@selector(recorder:didFinishRecord:)]) {
        [self.delegate recorder:self didFinishRecord:nil];
    }
}

@end
