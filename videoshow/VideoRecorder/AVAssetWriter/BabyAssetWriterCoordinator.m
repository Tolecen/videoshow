//
//  BabyAssetWriterCoordinator.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyAssetWriterCoordinator.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "BabyFileManager.h"

typedef NS_ENUM(NSInteger, WriterStatus){
    WriterStatusIdle = 0,
    WriterStatusPreparingToRecord,
    WriterStatusRecording,
    WriterStatusFinishingRecordingPart1, // waiting for inflight buffers to be appended
    WriterStatusFinishingRecordingPart2, // calling finish writing on the asset writer
    WriterStatusFinished,	// terminal state
    WriterStatusFailed		// terminal state
}; // internal state machine

@interface BabyAssetWriterCoordinator () <VideoRecorderCoordinatorDelegate>

@property (nonatomic, weak) id<BabyAssetWriterCoordinatorDelegate> delegate;

@property (nonatomic, assign) WriterStatus status;

@property (nonatomic) dispatch_queue_t writingQueue;
@property (nonatomic) dispatch_queue_t delegateCallbackQueue;

@property (nonatomic) NSString *URL;

//@property (nonatomic) AVAssetWriter *assetWriter;
@property (nonatomic) BOOL haveStartedSession;

@property (nonatomic) CMFormatDescriptionRef audioTrackSourceFormatDescription;
@property (nonatomic) NSDictionary *audioTrackSettings;
@property (nonatomic) AVAssetWriterInput *audioInput;

@property (nonatomic) CMFormatDescriptionRef videoTrackSourceFormatDescription;
@property (nonatomic) CGAffineTransform videoTrackTransform;
@property (nonatomic) NSDictionary *videoTrackSettings;
@property (nonatomic) AVAssetWriterInput *videoInput;

@property (strong, nonatomic) VideoRecorderCoordinator *recorder;

@property (assign, nonatomic) long recordStartTime;

@end

@implementation BabyAssetWriterCoordinator


- (instancetype)initWithURL:(NSString *)URL
{
    if (!URL) {
        return nil;
    }
    
    self = [super init];
    if (self) {
        _writingQueue = dispatch_queue_create( "com.mengbaopai.assetwriter.writing", DISPATCH_QUEUE_SERIAL );
        _videoTrackTransform = CGAffineTransformMakeRotation(M_PI_2); //portrait orientation
        _URL = URL;
        _isFrontCanera = NO;
        _recordStartTime = 0;
        _recorder = [[VideoRecorderCoordinator alloc]init];
        [_recorder setDelegate:self callbackQueue:dispatch_get_main_queue()];
    }
    return self;
}

- (void)addVideoTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)videoSettings
{
    if ( formatDescription == NULL ){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
        return;
    }
    @synchronized( self )
    {
        if (_status != WriterStatusIdle){
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
            return;
        }
        
        if(_videoTrackSourceFormatDescription ){
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one video track" userInfo:nil];
            return;
        }
        
        _videoTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
        _videoTrackSettings = [videoSettings copy];
    }
}

- (void)addAudioTrackWithSourceFormatDescription:(CMFormatDescriptionRef)formatDescription settings:(NSDictionary *)audioSettings
{
    if ( formatDescription == NULL ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL format description" userInfo:nil];
        return;
    }
    
    @synchronized( self )
    {
        if ( _status != WriterStatusIdle ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add tracks while not idle" userInfo:nil];
            return;
        }
        
        if ( _audioTrackSourceFormatDescription ) {
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Cannot add more than one audio track" userInfo:nil];
            return;
        }
        
        _audioTrackSourceFormatDescription = (CMFormatDescriptionRef)CFRetain( formatDescription );
        _audioTrackSettings = [audioSettings copy];
    }
}


- (void)setDelegate:(id<BabyAssetWriterCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue; // delegate is weak referenced
{
    if ( delegate && ( delegateCallbackQueue == NULL ) ) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Caller must provide a delegateCallbackQueue" userInfo:nil];
    }
    
    @synchronized( self )
    {
        _delegate = delegate;
        if ( delegateCallbackQueue != _delegateCallbackQueue  ) {
            _delegateCallbackQueue = delegateCallbackQueue;
        }
    }
}

- (void)setIsFrontCanera:(BOOL)isFrontCanera
{
    _isFrontCanera = isFrontCanera;
    DLog("_isFrontCanera : %d", _isFrontCanera);
}

- (void)prepareToRecord
{
    @synchronized( self )
    {
        if (_status != WriterStatusIdle){
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Already prepared, cannot prepare again" userInfo:nil];
            return;
        }
        [self transitionToStatus:WriterStatusPreparingToRecord error:nil];
    }
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_LOW, 0 ), ^{
        @autoreleasepool
        {
            NSError *error = nil;
            
            // Create and add inputs
            if (_videoTrackSourceFormatDescription) {
                [self setupAssetWriterVideoInputWithSourceFormatDescription:_videoTrackSourceFormatDescription transform:_videoTrackTransform settings:_videoTrackSettings error:&error];
            }
            if(_audioTrackSourceFormatDescription) {
                [self setupAssetWriterAudioInputWithSourceFormatDescription:_audioTrackSourceFormatDescription settings:_audioTrackSettings error:&error];
            }
            
            CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(_videoTrackSourceFormatDescription);
            DLog(@"video stream setup, width (%d) height (%d)", dimensions.width, dimensions.height);
            
            const AudioStreamBasicDescription *asbd = CMAudioFormatDescriptionGetStreamBasicDescription(_audioTrackSourceFormatDescription);
            if (!asbd) {
                DLog(@"audio stream description used with non-audio format description");
                
            }
            
            unsigned int channels = asbd->mChannelsPerFrame;
            double sampleRate = asbd->mSampleRate;
            
            DLog(@"audio stream setup, channels (%d) sampleRate (%f)", channels, sampleRate);
            int cameraSelection = _isFrontCanera ? 1 : 0;
//            NSString * overlayPath = [[[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:@"Common"]stringByAppendingPathComponent:@"frame_overlay_black2.jpg"];
//            UIImage * image = [UIImage imageWithContentsOfFile:overlayPath];
            [_recorder coorInitRecorder:_URL srcHight:dimensions.width cameraSelection:cameraSelection andHuafuHeight:weakSelf.outputHeight audioBitrate:64000 videoBitrate:1500 hasAudio:1 andOverlayName:@"null"];
           
//            [_recorder coorInitRecorder:_URL srcHight:dimensions.width videoHeight:640  cameraSelection:cameraSelection audioBitrate:64000 videoBitrate:1500 hasAudio:1 overFile:@"null"];

//            [_recorder coorInitRecorder:_URL srcHight:dimensions.width videoHeight:640  cameraSelection:cameraSelection audioBitrate:64000 videoBitrate:1500 hasAudio:1 overFile:@"null"];
            
        }
    } );
}

- (void)appendVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeVideo];
}

- (void)appendAudioSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    [self appendSampleBuffer:sampleBuffer ofMediaType:AVMediaTypeAudio];
}

- (void)finishRecording
{
    @synchronized(self)
    {
        BOOL shouldFinishRecording = NO;
        switch (_status)
        {
            case WriterStatusIdle:
            case WriterStatusPreparingToRecord:
            case WriterStatusFinishingRecordingPart1:
            case WriterStatusFinishingRecordingPart2:
            case WriterStatusFinished:
                @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not recording" userInfo:nil];
                break;
            case WriterStatusFailed:
                // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
                // Because of this we are lenient when finishRecording is called and we are in an error state.
                NSLog( @"Recording has failed, nothing to do" );
                break;
            case WriterStatusRecording:
                shouldFinishRecording = YES;
                break;
        }
        
        if (shouldFinishRecording){
            [self transitionToStatus:WriterStatusFinishingRecordingPart1 error:nil];
        }
        else {
            return;
        }
    }
    
    dispatch_async( _writingQueue, ^{
        @autoreleasepool
        {
            @synchronized(self)
            {
                // We may have transitioned to an error state as we appended inflight buffers. In that case there is nothing to do now.
                if ( _status != WriterStatusFinishingRecordingPart1 ) {
                    return;
                }
                
                // It is not safe to call -[AVAssetWriter finishWriting*] concurrently with -[AVAssetWriterInput appendSampleBuffer:]
                // We transition to MovieRecorderStatusFinishingRecordingPart2 while on _writingQueue, which guarantees that no more buffers will be appended.
                [self transitionToStatus:WriterStatusFinishingRecordingPart2 error:nil];
            }
            
            [_recorder coorRecordeClose];
        }
    } );
}


#pragma mark - Private methods

- (BOOL)setupAssetWriterAudioInputWithSourceFormatDescription:(CMFormatDescriptionRef)audioFormatDescription settings:(NSDictionary *)audioSettings error:(NSError **)errorOut
{
    if (!audioSettings) {
        audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                                                    [NSNumber numberWithUnsignedInt:1], AVNumberOfChannelsKey,
                                                  [NSNumber numberWithInt:64000], AVEncoderBitRateKey, nil];
    }
    _audioInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioFormatDescription];
    _audioInput.expectsMediaDataInRealTime = YES;
        
    
    return YES;
}

- (BOOL)setupAssetWriterVideoInputWithSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription transform:(CGAffineTransform)transform settings:(NSDictionary *)videoSettings error:(NSError **)errorOut
{
    if (!videoSettings){
        videoSettings = [self fallbackVideoSettingsForSourceFormatDescription:videoFormatDescription];
    }

    _videoInput = [[AVAssetWriterInput alloc] initWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoFormatDescription];
    _videoInput.expectsMediaDataInRealTime = YES;
    _videoInput.transform = transform;

    return YES;
}

- (NSDictionary *)fallbackVideoSettingsForSourceFormatDescription:(CMFormatDescriptionRef)videoFormatDescription
{
    float bitsPerPixel;
    CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(videoFormatDescription);
    int numPixels = dimensions.width * dimensions.height;
    int bitsPerSecond;
    DLog(@"video stream setup, width (%d) height (%d)", dimensions.width, dimensions.height);
    NSLog( @"No video settings provided, using default settings" );
    
    // Assume that lower-than-SD resolutions are intended for streaming, and use a lower bitrate
    if ( numPixels < ( 640 * 480 ) ) {
        bitsPerPixel = 4.05; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetMedium or Low.
    }
    else {
        bitsPerPixel = 10.1; // This bitrate approximately matches the quality produced by AVCaptureSessionPresetHigh.
    }
    
    bitsPerSecond = numPixels * bitsPerPixel;
    
    NSDictionary *compressionProperties = @{ AVVideoAverageBitRateKey : @(bitsPerSecond),
                                             AVVideoExpectedSourceFrameRateKey : @(30),
                                             AVVideoMaxKeyFrameIntervalKey : @(30) };
    
    return @{ AVVideoCodecKey : AVVideoCodecH264,
              AVVideoWidthKey : @(dimensions.width),
              AVVideoHeightKey : @(dimensions.height),
              (id)kCVPixelBufferPixelFormatTypeKey : [NSNumber numberWithUnsignedInt:kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange],
              AVVideoCompressionPropertiesKey : compressionProperties };
    
}

- (void)appendSampleBuffer:(CMSampleBufferRef)sampleBuffer ofMediaType:(NSString *)mediaType
{
    if(sampleBuffer == NULL){
        @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"NULL sample buffer" userInfo:nil];
        return;
    }
    
    @synchronized(self){
        if (_status < WriterStatusRecording){
            @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Not ready to record yet" userInfo:nil];
            return;
        }
    }
    
    CFRetain(sampleBuffer);
    dispatch_async( _writingQueue, ^{
        @autoreleasepool
        {
            @synchronized(self)
            {
                // From the client's perspective the movie recorder can asynchronously transition to an error state as the result of an append.
                // Because of this we are lenient when samples are appended and we are no longer recording.
                // Instead of throwing an exception we just release the sample buffers and return.
                if (_status > WriterStatusFinishingRecordingPart1){
                    CFRelease(sampleBuffer);
                    return;
                }
            }
            
            
            
            if (mediaType == AVMediaTypeVideo) {
                
                CMTime pts = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
                long second = pts.value / 1000000;
                
                if (_recordStartTime == 0) {
                    _recordStartTime = second;
                }
                
                long timeStramp = second - _recordStartTime;
                
                CVImageBufferRef videoBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
                CVPixelBufferLockBaseAddress(videoBuffer,0);
                
                void *src_buff = CVPixelBufferGetBaseAddress(videoBuffer);
                
                [_recorder coorRecordeVideo:src_buff timestamp:timeStramp];
                
                CVPixelBufferUnlockBaseAddress(videoBuffer, 0);
                
                
//                CVPixelBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//                
//                if (CVPixelBufferLockBaseAddress(imageBuffer, 0) == kCVReturnSuccess) {
//                    
////                        int pixelFormat = CVPixelBufferGetPixelFormatType(imageBuffer);
////                        switch (pixelFormat) {
////                            case kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange:
////                                NSLog(@"Capture pixel format=NV12");
////                                break;
////                            case kCVPixelFormatType_422YpCbCr8:
////                                NSLog(@"Capture pixel format=UYUY422");
////                                break;
////                            default:
////                                NSLog(@"Capture pixel format=RGB32");
////                                break;
////                        }
//                    
//                    
//                    UInt8 *bufferbasePtr = (UInt8 *)CVPixelBufferGetBaseAddress(imageBuffer);
//                    UInt8 *bufferPtr = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,0);
//                    UInt8 *bufferPtr1 = (UInt8 *)CVPixelBufferGetBaseAddressOfPlane(imageBuffer,1);
//                    size_t buffeSize = CVPixelBufferGetDataSize(imageBuffer);
//                    size_t width = CVPixelBufferGetWidth(imageBuffer);
//                    size_t height = CVPixelBufferGetHeight(imageBuffer);
//                    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
//                    size_t bytesrow0 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,0);
//                    size_t bytesrow1  = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,1);
//                    size_t bytesrow2 = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer,2);
//                    UInt8 *yuv420_data = (UInt8 *)malloc(width * height *3/ 2); // buffer to store YUV with layout YYYYYYYYUUVV
//                    
//                    /* convert NV12 data to YUV420*/
//                    UInt8 *pY = bufferPtr ;
//                    UInt8 *pUV = bufferPtr1;
//                    UInt8 *pU = yuv420_data + width*height;
//                    UInt8 *pV = pU + width*height/4;
//                    for(int i =0;i<height;i++)
//                    {
//                        memcpy(yuv420_data+i*width,pY+i*bytesrow0,width);
//                    }
//                    for(int j = 0;j<height/2;j++)
//                    {
//                        for(int i =0;i<width/2;i++)
//                        {
//                            *(pU++) = pUV[i<<1];
//                            *(pV++) = pUV[(i<<1) + 1];
//                        }
//                        pUV+=bytesrow1;
//                    }
//                    
//                    //Read raw YUV data
//                    [_recorder coorRecordeVideo:yuv420_data timestamp:timeStramp];
//                    
//                    free(yuv420_data);
//                }
                
//                CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
                
                
                
            } else {
                
                CMBlockBufferRef audioBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
                size_t lengthAtOffset;
                size_t totalLength;
                char *samples;
                CMBlockBufferGetDataPointer(audioBuffer, 0, &lengthAtOffset, &totalLength, &samples);
                
//                DLog(@"audio===============================srart==");
//                
//                DLog(@"audio : lengthAtOffset = %zu", lengthAtOffset);
//                DLog(@"audio : totalLength = %zu", totalLength);
//                DLog(@"audio : samples = %s", samples);
//                DLog(@"audio : format = %@", format);
//                
//                DLog(@"audio===============================e n d==");
                
                [_recorder coorRecordeAudio:samples numSamples:totalLength / 2];
            }

            CFRelease(sampleBuffer);
        }
    } );
}

// call under @synchonized( self )
- (void)transitionToStatus:(WriterStatus)newStatus error:(NSError *)error
{
    BOOL shouldNotifyDelegate = NO;
    
    if (newStatus != _status){
        // terminal states
        if ((newStatus == WriterStatusFinished) || (newStatus == WriterStatusFailed)){
            shouldNotifyDelegate = YES;
            // make sure there are no more sample buffers in flight before we tear down the asset writer and inputs
            
            dispatch_async(_writingQueue, ^{
                _videoInput = nil;
                _audioInput = nil;
            } );
        } else if (newStatus == WriterStatusRecording){
            shouldNotifyDelegate = YES;
        }
        _status = newStatus;
    }
    
    if (shouldNotifyDelegate && self.delegate){
        dispatch_async( _delegateCallbackQueue, ^{
            
            @autoreleasepool
            {
                switch(newStatus){
                    case WriterStatusRecording:
                        [self.delegate writerCoordinatorDidFinishPreparing:self];
                        break;
                    case WriterStatusFinished:
                        [self.delegate writerCoordinatorDidFinishRecording:self];
                        break;
                    case WriterStatusFailed:
                        [self.delegate writerCoordinator:self didFailWithError:error];
                        break;
                    default:
                        break;
                }
            }
        });
    }
}

- (NSError *)cannotSetupInputError
{
    NSString *localizedDescription = NSLocalizedString( @"Recording cannot be started", nil );
    NSString *localizedFailureReason = NSLocalizedString( @"Cannot setup asset writer input.", nil );
    NSDictionary *errorDict = @{ NSLocalizedDescriptionKey : localizedDescription,
                                 NSLocalizedFailureReasonErrorKey : localizedFailureReason };
    return [NSError errorWithDomain:@"com.mengbaopai" code:0 userInfo:errorDict];
}


/**
 *  初始化完毕
 *
 *  @param recorder recorder
 *  @param error    有没有error
 */
- (void)recorder:(VideoRecorderCoordinator *)recorder didFinishInit:(NSError *)error
{
    [self transitionToStatus:WriterStatusRecording error:nil];
}

/**
 *  录制一段视频完成
 *
 *  @param recorder recorder
 *  @param error    有没有error
 */
- (void)recorder:(VideoRecorderCoordinator *)recorder didFinishRecord:(NSError *)error
{
    
    BOOL isE = [[NSFileManager defaultManager] fileExistsAtPath:_URL];
    
    NSLog(@"%@ ---- %d", _URL, isE);
    
    [self transitionToStatus:WriterStatusFinished error:nil];
    
}


@end
