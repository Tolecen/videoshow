//
//  BabyAssetWriterCoordinator.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <AVFoundation/AVFoundation.h>

@protocol BabyAssetWriterCoordinatorDelegate;

@interface BabyAssetWriterCoordinator : NSObject

- (instancetype)initWithURL:(NSString *)URL;
- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)videoSettings;
- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings;
- (void)setDelegate:(id<BabyAssetWriterCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

- (void)prepareToRecord;
- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)finishRecording;

@property (nonatomic, assign)int outputHeight;
@property (nonatomic, assign)BOOL isCircle;

@property (nonatomic, assign) BOOL isFrontCanera;

@end


@protocol BabyAssetWriterCoordinatorDelegate <NSObject>

- (void)writerCoordinatorDidFinishPreparing:(BabyAssetWriterCoordinator *)coordinator;
- (void)writerCoordinator:(BabyAssetWriterCoordinator *)coordinator didFailWithError:(NSError *)error;
- (void)writerCoordinatorDidFinishRecording:(BabyAssetWriterCoordinator *)coordinator;

@end
