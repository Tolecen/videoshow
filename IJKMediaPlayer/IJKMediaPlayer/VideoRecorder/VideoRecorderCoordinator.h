//
//  VideoRecorderCoordinator.h
//  IJKMediaPlayer
//
//  Created by ning on 16/4/30.
//  Copyright © 2016年 bilibili. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  VideoRecorderCoordinatorDelegate;

@interface VideoRecorderCoordinator : NSObject

@property (nonatomic, strong) dispatch_queue_t delegateCallbackQueue;
@property (nonatomic, weak) id<VideoRecorderCoordinatorDelegate> delegate;

- (void)setDelegate:(id<VideoRecorderCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

- (void)coorInitRecorder:(NSString *)fileName srcHight:(int)srcHight cameraSelection:(int)cameraSelection andHuafuHeight:(int)huafuHeight audioBitrate:(long)audioBitrate videoBitrate:(long)videoBitrate hasAudio:(int)hasAudio andOverlayName:(NSString *)overlayName;

- (void)coorSetRecorderInfo:(int)srcHight cameraSelection:(int)cameraSelection;

- (void)coorRecordeVideo:(void *)frame timestamp:(long)timestamp;

- (void)coorRecordeAudio:(void *)samples numSamples:(long)numSamples;

- (void)coorRecordeClose;

@end

@protocol VideoRecorderCoordinatorDelegate <NSObject>

@required

/**
 *  初始化完毕
 *
 *  @param recorder recorder
 *  @param error    有没有error
 */
- (void)recorder:(VideoRecorderCoordinator *)recorder didFinishInit:(NSError *)error;

/**
 *  录制一段视频完成
 *
 *  @param recorder recorder
 *  @param error    有没有error
 */
- (void)recorder:(VideoRecorderCoordinator *)recorder didFinishRecord:(NSError *)error;

@end
