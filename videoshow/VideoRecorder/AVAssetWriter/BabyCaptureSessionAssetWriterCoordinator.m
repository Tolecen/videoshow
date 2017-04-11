//
//  BabyCaptureSessionAssetWriterCoordinator.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyCaptureSessionAssetWriterCoordinator.h"

#import <MobileCoreServices/MobileCoreServices.h>
#import "BabyAssetWriterCoordinator.h"
#import "BabyFileManager.h"
#import <IJKMediaFramework/VideoEncoder.h>


typedef NS_ENUM( NSInteger, RecordingStatus )
{
    RecordingStatusIdle = 0,
    RecordingStatusStartingRecording,
    RecordingStatusRecording,
    RecordingStatusStoppingRecording,
}; // internal state machine


#define COUNT_DUR_TIMER_INTERVAL 0.05

@interface BabyCaptureSessionAssetWriterCoordinator () <AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate, BabyAssetWriterCoordinatorDelegate>

@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) dispatch_queue_t audioDataOutputQueue;

@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) AVCaptureAudioDataOutput *audioDataOutput;

@property (nonatomic, strong) AVCaptureConnection *audioConnection;
@property (nonatomic, strong) AVCaptureConnection *videoConnection;

@property (nonatomic, strong) NSDictionary *videoCompressionSettings;
@property (nonatomic, strong) NSDictionary *audioCompressionSettings;

@property (nonatomic, assign) RecordingStatus recordingStatus;

@property(nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputVideoFormatDescription;
@property(nonatomic, retain) __attribute__((NSObject)) CMFormatDescriptionRef outputAudioFormatDescription;
@property(nonatomic, retain) BabyAssetWriterCoordinator *assetWriterCoordinator;


@property (strong, nonatomic) NSTimer *countDurTimer;
@property (assign, nonatomic) BOOL isRecording;


@end

@implementation BabyCaptureSessionAssetWriterCoordinator


- (instancetype)init
{
    self = [super init];
    if(self){
        self.videoDataOutputQueue = dispatch_queue_create( "com.mengbaopai.capturesession.videodata", DISPATCH_QUEUE_SERIAL );
        dispatch_set_target_queue( _videoDataOutputQueue, dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ) );
        self.audioDataOutputQueue = dispatch_queue_create( "com.mengbaopai.capturesession.audiodata", DISPATCH_QUEUE_SERIAL );
        [self addDataOutputsToCaptureSession:self.captureSession];
        
        
    }
    return self;
}

- (void)startCountDurTimer
{
    [self.mMediaObject getCurrentPart].startTime = (double)[[NSDate date] timeIntervalSince1970]*1000;
    self.isRecording = YES;
    self.countDurTimer = [NSTimer scheduledTimerWithTimeInterval:COUNT_DUR_TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)onTimer:(NSTimer *)timer
{
    
    if ([self.delegate respondsToSelector:@selector(coordinator:didRecordingToOutPutFileAtURL:duration:recordedVideosTotalDur:mediaObject:)]) {
        [self.delegate coordinator:self didRecordingToOutPutFileAtURL:[self.mMediaObject getCurrentPart].mediaPath duration:[[self.mMediaObject getCurrentPart] getDuration] recordedVideosTotalDur:[self.mMediaObject getDuration] mediaObject:self.mMediaObject];
    }
    if ([self.mMediaObject getDuration] >= self.mMediaObject.mMaxDuration) {
        [self stopRecording];
    }
}

- (void)stopCountDurTimer
{
    [_countDurTimer invalidate];
    self.countDurTimer = nil;
}


//总时长
- (CGFloat)getTotalVideoDuration
{
    return [self.mMediaObject getRealDuration];
}

//现在录了多少视频
- (NSUInteger)getVideoCount
{
    return [self.mMediaObject.mMediaList count];
}

//不调用delegate
- (void)deleteAllVideo
{
    [self.mMediaObject deleteObject];
}

//会调用delegate
- (void)deleteLastVideo
{
    NSString *removeVideoPath = nil;
    if (self.mMediaObject != nil) {
        MediaPart *part = [self.mMediaObject getCurrentPart];
        if (part != nil) {
            removeVideoPath = part.mediaPath;
            [self.mMediaObject removePart:part deleteData:YES];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //delegate
        if ([self.delegate respondsToSelector:@selector(coordinator:didRemoveVideoFileAtURL:totalDur:mediaObject:error:)]) {
            [self.delegate coordinator:self didRemoveVideoFileAtURL:removeVideoPath totalDur:[self.mMediaObject getRealDuration] mediaObject:self.mMediaObject error:nil];
        }
    });
}

- (void)mergeVideoFiles
{
    
    
    __block BabyCaptureSessionAssetWriterCoordinator *blockSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *concatPath = [BabyFileManager getVideoMergeFilePathString:blockSelf.mMediaObject.mOutputDirectory concatText:[self.mMediaObject getConcatYUV]];
        DLog(@"concatPath : %@", concatPath);
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-f"];
        [mutableArray addObject:@"concat"];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:concatPath];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c"];
        [mutableArray addObject:@"copy"];
        [mutableArray addObject:@"-absf"];
        [mutableArray addObject:@"aac_adtstoasc"];
        [mutableArray addObject:@"-movflags"];
        [mutableArray addObject:@"+faststart"];
        [mutableArray addObject:[self.mMediaObject getOutputTempVideoPath]];
        
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, (double)timestamp / ([blockSelf.mMediaObject getDuration] * 1000));
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            if ([blockSelf.delegate respondsToSelector:@selector(coordinator:didFinishMergingVideosToOutPutFileAtURL:mediaObject:)]) {
                [blockSelf.delegate coordinator:blockSelf didFinishMergingVideosToOutPutFileAtURL:[blockSelf.mMediaObject getOutputTempVideoPath] mediaObject:blockSelf.mMediaObject];
            }
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
        
    });
    

    
    
}

#pragma mark - Recording

- (void)startRecording
{
    @synchronized(self)
    {
        
        if (self.captureSession == nil) {
            DLog(@"初始化Session失败");
            return;
        }
        
        if(_recordingStatus != RecordingStatusIdle) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already recording" userInfo:nil];
            return;
        }
        if ([self.mMediaObject getRealDuration] >= self.mMediaObject.mMaxDuration) {
            
            DLog(@"[self.mMediaObject getRealDuration] : %d", [self.mMediaObject getRealDuration]);
            DLog(@"self.mMediaObject.mMaxDuration : %d", self.mMediaObject.mMaxDuration);
            
            DLog(@"视频总长达到最大");
            
            return;
        }
        [self transitionToRecordingStatus:RecordingStatusStartingRecording error:nil];
    }
    self.isRecording = NO;
    int mCameraId = self.isUsingFrontCamera ? 1 : 0;
    
    MediaPart *mMediaPart = [self.mMediaObject buildMediaPart:mCameraId videoSuffix:@".mp4"];
    self.mMediaObject.isRecording = YES;
    
    DLog(@"mMediaPart : mediaPath : %@", mMediaPart.mediaPath);
    self.assetWriterCoordinator = [[BabyAssetWriterCoordinator alloc] initWithURL:mMediaPart.mediaPath];
    [_assetWriterCoordinator setIsFrontCanera:self.isUsingFrontCamera];
    if(_outputAudioFormatDescription != nil){
        [_assetWriterCoordinator addAudioTrackWithSourceFormatDescription:self.outputAudioFormatDescription settings:_audioCompressionSettings];
    }
    [_assetWriterCoordinator addVideoTrackWithSourceFormatDescription:self.outputVideoFormatDescription settings:_videoCompressionSettings];
    
    dispatch_queue_t callbackQueue = dispatch_queue_create("com.mengbaopai.capturesession.writercallback", DISPATCH_QUEUE_SERIAL ); // guarantee ordering of callbacks with a serial queue
    [_assetWriterCoordinator setDelegate:self callbackQueue:callbackQueue];
    _assetWriterCoordinator.outputHeight = self.outputHeight;
    _assetWriterCoordinator.isCircle = self.isCircle;
    [_assetWriterCoordinator prepareToRecord]; // asynchronous, will call us back with recorderDidFinishPreparing: or recorder:didFailWithError: when done
    
}



- (void)stopRecording
{
    @synchronized(self)
    {
        if (_recordingStatus != RecordingStatusRecording){
            return;
        }
        self.isRecording = NO;
        [self stopCountDurTimer];
        [self transitionToRecordingStatus:RecordingStatusStoppingRecording error:nil];
    }
    
    // 判断数据是否处理完，处理完了关闭输出流
    if (self.mMediaObject != nil) {
        MediaPart *part = [self.mMediaObject getCurrentPart];
        if (part != nil && part.recording) {
            part.recording = NO;
            part.endTime = (double)[[NSDate date] timeIntervalSince1970]*1000;
            part.duration = (int) ([[NSDate date] timeIntervalSince1970]*1000 - part.startTime);
            part.cutStartTime = 0;
            part.cutEndTime = part.duration;
        }
    }
    
    [self.assetWriterCoordinator finishRecording]; // asynchronous, will call us back with
}

- (void)switchCamera
{
    [super switchCamera];
    
    [self.captureSession beginConfiguration];
    [self.captureSession removeOutput:_videoDataOutput];

    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    _videoDataOutput.videoSettings = nil;
    _videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    
    [self addOutput:_videoDataOutput toCaptureSession:self.captureSession];
    _videoConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self setCompressionSettings];
    [self.captureSession commitConfiguration];
    
}

#pragma mark - Private methods

- (void)addDataOutputsToCaptureSession:(AVCaptureSession *)captureSession
{
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    _videoDataOutput.videoSettings = nil;
    _videoDataOutput.alwaysDiscardsLateVideoFrames = NO;
    [_videoDataOutput setSampleBufferDelegate:self queue:_videoDataOutputQueue];
    
    self.audioDataOutput = [AVCaptureAudioDataOutput new];
    [_audioDataOutput setSampleBufferDelegate:self queue:_audioDataOutputQueue];
    
    [self addOutput:_videoDataOutput toCaptureSession:self.captureSession];
    _videoConnection = [_videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self addOutput:_audioDataOutput toCaptureSession:self.captureSession];
    _audioConnection = [_audioDataOutput connectionWithMediaType:AVMediaTypeAudio];
    
    [self setCompressionSettings];
}

- (void)setupVideoPipelineWithInputFormatDescription:(CMFormatDescriptionRef)inputFormatDescription
{
    self.outputVideoFormatDescription = inputFormatDescription;
}

- (void)teardownVideoPipeline
{
    self.outputVideoFormatDescription = nil;
}

- (void)setCompressionSettings
{
    _videoCompressionSettings = [_videoDataOutput recommendedVideoSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
//    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:_videoCompressionSettings];
////    NSDictionary *videoSettings = @{
////                                    AVVideoCodecKey  : AVVideoCodecH264
////                                    , AVVideoWidthKey  : @(100)
////                                    , AVVideoHeightKey : @(100)
////                                    };
//    [dict setObject:AVVideoCodecH264 forKey:AVVideoCodecKey];
//    [dict setObject:@"480" forKey:AVVideoWidthKey];
//    [dict setObject:@"100" forKey:AVVideoHeightKey];
//    _videoCompressionSettings = dict;
    _audioCompressionSettings = [_audioDataOutput recommendedAudioSettingsForAssetWriterWithOutputFileType:AVFileTypeMPEG4];
}

#pragma mark - SampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    CMFormatDescriptionRef formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer);
    
    if (connection == _videoConnection){
        
//        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(formatDescription);
//        DLog(@"video stream setup, width (%d) height (%d) \n", dimensions.width, dimensions.height);
        
        if (self.outputVideoFormatDescription == nil) {
            [self setupVideoPipelineWithInputFormatDescription:formatDescription];
        } else {
            self.outputVideoFormatDescription = formatDescription;
            
            if (!self.isRecording) {
                return;
            }
            
            @synchronized(self) {
                if(_recordingStatus == RecordingStatusRecording){
                    [_assetWriterCoordinator appendVideoSampleBuffer:sampleBuffer];
                }
            }
        }
    } else if ( connection == _audioConnection ){
        self.outputAudioFormatDescription = formatDescription;
        
        if (!self.isRecording) {
            return;
        }
        
        @synchronized( self ) {
            if(_recordingStatus == RecordingStatusRecording){
                [_assetWriterCoordinator appendAudioSampleBuffer:sampleBuffer];
            }
        }
    }
}

#pragma mark - BabyAssetWriterCoordinatorDelegate methods

- (void)writerCoordinatorDidFinishPreparing:(BabyAssetWriterCoordinator *)coordinator
{
    @synchronized(self)
    {
        if(_recordingStatus != RecordingStatusStartingRecording){
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StartingRecording state" userInfo:nil];
            return;
        }
        [self transitionToRecordingStatus:RecordingStatusRecording error:nil];
    }
}

- (void)writerCoordinator:(BabyAssetWriterCoordinator *)recorder didFailWithError:(NSError *)error
{
    @synchronized( self ) {
        self.assetWriterCoordinator = nil;
        [self transitionToRecordingStatus:RecordingStatusIdle error:error];
    }
    [self deleteLastVideo];
}

- (void)writerCoordinatorDidFinishRecording:(BabyAssetWriterCoordinator *)coordinator
{
    @synchronized( self )
    {
        if ( _recordingStatus != RecordingStatusStoppingRecording ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Expected to be in StoppingRecording state" userInfo:nil];
            return;
        }
        // No state transition, we are still in the process of stopping.
        // We will be stopped once we save to the assets library.
    }
    
    self.assetWriterCoordinator = nil;
    
    @synchronized( self ) {
        [self transitionToRecordingStatus:RecordingStatusIdle error:nil];
    }
}


#pragma mark - Recording State Machine

// call under @synchonized( self )
- (void)transitionToRecordingStatus:(RecordingStatus)newStatus error:(NSError *)error
{
    RecordingStatus oldStatus = _recordingStatus;
    _recordingStatus = newStatus;
    
    if (newStatus != oldStatus){
        if (error && (newStatus == RecordingStatusIdle)){
            dispatch_async( self.delegateCallbackQueue, ^{
                @autoreleasepool
                {
                    DLog(@"发生错误: %@", [error localizedDescription]);
                }
            });
        } else {
            error = nil; // only the above delegate method takes an error
            if (oldStatus == RecordingStatusStartingRecording && newStatus == RecordingStatusRecording){
                dispatch_async( self.delegateCallbackQueue, ^{
                    @autoreleasepool
                    {
                        [self startCountDurTimer];
                        
                        if ([self.delegate respondsToSelector:@selector(coordinator:didStartRecordingToOutPutFileAtURL:mediaObject:)]) {
                            [self.delegate coordinator:self didStartRecordingToOutPutFileAtURL:[self.mMediaObject getCurrentPart].mediaPath mediaObject:self.mMediaObject];
                        }
                    }
                });
            } else if (oldStatus == RecordingStatusStoppingRecording && newStatus == RecordingStatusIdle) {
                dispatch_async( self.delegateCallbackQueue, ^{
                    @autoreleasepool
                    {
                        
                        DLog(@"本段视频长度: %d", [[self.mMediaObject getCurrentPart] getRealDuration]);
                        DLog(@"现在的视频总长度: %d", [self.mMediaObject getRealDuration]);
                        
                        if ([self.delegate respondsToSelector:@selector(coordinator:didFinishRecordingToOutPutFileAtURL:duration:totalDur:mediaObject:error:)]) {
                            [self.delegate coordinator:self didFinishRecordingToOutPutFileAtURL:[self.mMediaObject getCurrentPart].mediaPath duration:[[self.mMediaObject getCurrentPart] getRealDuration] totalDur:[self.mMediaObject getRealDuration] mediaObject:self.mMediaObject error:nil];
                        }
                        
                    }
                });
            }
        }
    }
}

@end
