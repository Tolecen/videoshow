//
//  BabyCaptureSessionCoordinator.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "MediaObject.h"
#import "MediaPart.h"

@protocol BabyCaptureSessionCoordinatorDelegate;

@interface BabyCaptureSessionCoordinator : NSObject

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDevice *cameraDevice;
@property (nonatomic, strong) dispatch_queue_t delegateCallbackQueue;
@property (nonatomic, strong) MediaObject *mMediaObject;
@property (nonatomic, weak) id<BabyCaptureSessionCoordinatorDelegate> delegate;

- (void)setDelegate:(id<BabyCaptureSessionCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue;

- (void)setMediaObject:(MediaObject *)mediaObject;

- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession;
- (BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession;

- (void)startRunning;
- (void)stopRunning;

- (void)startRecording;
- (void)stopRecording;

- (AVCaptureVideoPreviewLayer *)previewLayer;

@property (strong, nonatomic) AVCaptureDeviceInput *videoDeviceInput;


- (BOOL)isCameraSupported;
- (BOOL)isFrontCameraSupported;
- (BOOL)isTorchSupported;
- (BOOL)isUsingFrontCamera;

- (void)switchCamera;
- (void)openTorch:(BOOL)open;

- (void)focusInPoint:(CGPoint)touchPoint;

@end

@protocol BabyCaptureSessionCoordinatorDelegate <NSObject>

@required

//recorder开始录制一段视频时
- (void)coordinator:(BabyCaptureSessionCoordinator *)coordinator didStartRecordingToOutPutFileAtURL:(NSString *)outputFileURL mediaObject:(MediaObject *)mediaObject;

//recorder完成一段视频的录制时
- (void)coordinator:(BabyCaptureSessionCoordinator *)coordinator didFinishRecordingToOutPutFileAtURL:(NSString *)outputFileURL duration:(int)videoDuration totalDur:(int)totalDur mediaObject:(MediaObject *)mediaObject error:(NSError *)error;

//recorder正在录制的过程中
- (void)coordinator:(BabyCaptureSessionCoordinator *)coordinator didRecordingToOutPutFileAtURL:(NSString *)outputFileURL duration:(int)videoDuration recordedVideosTotalDur:(int)totalDur mediaObject:(MediaObject *)mediaObject;

//recorder删除了某一段视频
- (void)coordinator:(BabyCaptureSessionCoordinator *)coordinator didRemoveVideoFileAtURL:(NSString *)fileURL totalDur:(CGFloat)totalDur mediaObject:(MediaObject *)mediaObject error:(NSError *)error;

//recorder完成视频的合成
- (void)coordinator:(BabyCaptureSessionCoordinator *)coordinator didFinishMergingVideosToOutPutFileAtURL:(NSString *)outputFileURL mediaObject:(MediaObject *)mediaObject ;

@end
