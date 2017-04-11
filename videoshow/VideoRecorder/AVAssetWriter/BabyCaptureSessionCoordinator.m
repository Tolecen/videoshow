//
//  BabyCaptureSessionCoordinator.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyCaptureSessionCoordinator.h"


@interface BabyCaptureSessionCoordinator ()

@property (nonatomic, strong) dispatch_queue_t sessionQueue;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@property (assign, nonatomic) BOOL isFrontCameraSupported;
@property (assign, nonatomic) BOOL isCameraSupported;
@property (assign, nonatomic) BOOL isTorchSupported;
@property (assign, nonatomic) BOOL isTorchOn;
@property (assign, nonatomic) BOOL isUsingFrontCamera;


@end

@implementation BabyCaptureSessionCoordinator


- (instancetype)init
{
    self = [super init];
    if(self){
        _sessionQueue = dispatch_queue_create( "com.mengbaopai.capturepipeline.session", DISPATCH_QUEUE_SERIAL );
        _captureSession = [self setupCaptureSession];
    }
    return self;
}

- (void)setMediaObject:(MediaObject *)mediaObject
{
    self.mMediaObject = mediaObject;
}

- (void)setDelegate:(id<BabyCaptureSessionCoordinatorDelegate>)delegate callbackQueue:(dispatch_queue_t)delegateCallbackQueue
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

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if(!_previewLayer && _captureSession){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

- (void)startRunning
{
    dispatch_sync( _sessionQueue, ^{
        [_captureSession startRunning];
    } );
}

- (void)stopRunning
{
    dispatch_sync( _sessionQueue, ^{
        // the captureSessionDidStopRunning method will stop recording if necessary as well, but we do it here so that the last video and audio samples are better aligned
        [self stopRecording]; // does nothing if we aren't currently recording
        [_captureSession stopRunning];
    } );
}


- (void)startRecording
{
    //overwritten by subclass
}

- (void)stopRecording
{
    //overwritten by subclass
}

- (BOOL)isTorchSupported
{
    return _isTorchSupported;
}

- (BOOL)isFrontCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isCameraSupported
{
    return _isFrontCameraSupported;
}

- (BOOL)isUsingFrontCamera
{
    return _isUsingFrontCamera;
}

- (void)focusInPoint:(CGPoint)touchPoint
{
    CGPoint devicePoint = [self convertToPointOfInterestFromViewCoordinates:touchPoint];
    NSLog(@"devicePoint.width=%f,devicePoint.height=%f",devicePoint.x,devicePoint.y);
    
    
    [self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)openTorch:(BOOL)open
{
    self.isTorchOn = open;
    if (!_isTorchSupported) {
        return;
    }
    
    AVCaptureTorchMode torchMode;
    if (open) {
        torchMode = AVCaptureTorchModeOn;
    } else {
        torchMode = AVCaptureTorchModeOff;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        [device lockForConfiguration:nil];
        [device setTorchMode:torchMode];
        [device unlockForConfiguration];
    });
}

- (void)switchCamera
{
    if (!_isFrontCameraSupported || !_isCameraSupported || !_videoDeviceInput) {
        return;
    }
    
    if (_isTorchOn) {
        [self openTorch:NO];
    }
    
    [_captureSession beginConfiguration];
    
    [_captureSession removeInput:_videoDeviceInput];
    
    self.isUsingFrontCamera = !_isUsingFrontCamera;
    AVCaptureDevice *device = [self getCameraDevice:_isUsingFrontCamera];
    
    [device lockForConfiguration:nil];
    if ([device isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [device unlockForConfiguration];
    
    NSError *error;
    _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error){
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
    } else {
        
        if ([_captureSession canAddInput:_videoDeviceInput]) {
            [_captureSession addInput:_videoDeviceInput];
        }
        
        _cameraDevice = _videoDeviceInput.device;
    }
    [_captureSession commitConfiguration];
    
}


- (AVCaptureDevice *)getCameraDevice:(BOOL)isFront
{
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    
    AVCaptureDevice *frontCamera;
    AVCaptureDevice *backCamera;
    
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionBack) {
            backCamera = camera;
        } else {
            frontCamera = camera;
        }
    }
    
    if (isFront) {
        return frontCamera;
    }
    
    return backCamera;
}

- (CGPoint)convertToPointOfInterestFromViewCoordinates:(CGPoint)viewCoordinates {
    CGPoint pointOfInterest = CGPointMake(.5f, .5f);
    CGSize frameSize = _previewLayer.bounds.size;
    
    AVCaptureVideoPreviewLayer *videoPreviewLayer = self.previewLayer;//需要按照项目实际情况修改
    
    if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResize]) {
        pointOfInterest = CGPointMake(viewCoordinates.y / frameSize.height, 1.f - (viewCoordinates.x / frameSize.width));
    } else {
        CGRect cleanAperture;
        
        for(AVCaptureInputPort *port in [self.videoDeviceInput ports]) {//需要按照项目实际情况修改，必须是正在使用的videoInput
            if([port mediaType] == AVMediaTypeVideo) {
                cleanAperture = CMVideoFormatDescriptionGetCleanAperture([port formatDescription], YES);
                CGSize apertureSize = cleanAperture.size;
                CGPoint point = viewCoordinates;
                
                CGFloat apertureRatio = apertureSize.height / apertureSize.width;
                CGFloat viewRatio = frameSize.width / frameSize.height;
                CGFloat xc = .5f;
                CGFloat yc = .5f;
                
                if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspect]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = frameSize.height;
                        CGFloat x2 = frameSize.height * apertureRatio;
                        CGFloat x1 = frameSize.width;
                        CGFloat blackBar = (x1 - x2) / 2;
                        if(point.x >= blackBar && point.x <= blackBar + x2) {
                            xc = point.y / y2;
                            yc = 1.f - ((point.x - blackBar) / x2);
                        }
                    } else {
                        CGFloat y2 = frameSize.width / apertureRatio;
                        CGFloat y1 = frameSize.height;
                        CGFloat x2 = frameSize.width;
                        CGFloat blackBar = (y1 - y2) / 2;
                        if(point.y >= blackBar && point.y <= blackBar + y2) {
                            xc = ((point.y - blackBar) / y2);
                            yc = 1.f - (point.x / x2);
                        }
                    }
                } else if([[videoPreviewLayer videoGravity]isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
                    if(viewRatio > apertureRatio) {
                        CGFloat y2 = apertureSize.width * (frameSize.width / apertureSize.height);
                        xc = (point.y + ((y2 - frameSize.height) / 2.f)) / y2;
                        yc = (frameSize.width - point.x) / frameSize.width;
                    } else {
                        CGFloat x2 = apertureSize.height * (frameSize.height / apertureSize.width);
                        yc = 1.f - ((point.x + ((x2 - frameSize.width) / 2)) / x2);
                        xc = point.y / frameSize.height;
                    }
                    
                }
                
                pointOfInterest = CGPointMake(xc, yc);
                break;
            }
        }
    }
    
    return pointOfInterest;
}

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange {
    //    NSLog(@"focus point: %f %f", point.x, point.y);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AVCaptureDevice *device = [_videoDeviceInput device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error]) {
            if ([device isFocusPointOfInterestSupported]) {
                [device setFocusPointOfInterest:point];
            }
            
            if ([device isFocusModeSupported:focusMode]) {
                [device setFocusMode:focusMode];
            }
            
            if ([device isExposurePointOfInterestSupported]) {
                [device setExposurePointOfInterest:point];
            }
            
            if ([device isExposureModeSupported:exposureMode]) {
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        } else {
            NSLog(@"对焦错误:%@", error);
        }
    });
}



#pragma mark - Capture Session Setup


- (AVCaptureSession *)setupCaptureSession
{
    AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
    
    [captureSession beginConfiguration];
    
    if(![self addDefaultCameraInputToCaptureSession:captureSession]){
        NSLog(@"failed to add camera input to capture session");
        return nil;
    }
    if(![self addDefaultMicInputToCaptureSession:captureSession]){
        NSLog(@"failed to add mic input to capture session");
        return nil;
    }
    
    NSString *sessionPreset = [captureSession sessionPreset];
    
    // setup video to use 640 x 480 for the hightest quality touch-to-record
    if ( [captureSession canSetSessionPreset:AVCaptureSessionPreset640x480] )
        sessionPreset = AVCaptureSessionPreset640x480;
    
    // apply presets
    if ([captureSession canSetSessionPreset:sessionPreset]) {
        [captureSession setSessionPreset:sessionPreset];
    }
    [captureSession commitConfiguration];
    return captureSession;
}

- (BOOL)addDefaultCameraInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    
    //input
    AVCaptureDevice *frontCamera = nil;
    AVCaptureDevice *backCamera = nil;
    
    NSArray *cameras = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *camera in cameras) {
        if (camera.position == AVCaptureDevicePositionFront) {
            frontCamera = camera;
        } else {
            backCamera = camera;
        }
    }
    
    if (!backCamera) {
        self.isCameraSupported = NO;
        return NO;
    } else {
        self.isCameraSupported = YES;
        
        if ([backCamera hasTorch]) {
            self.isTorchSupported = YES;
        } else {
            self.isTorchSupported = NO;
        }
    }
    
    if (!frontCamera) {
        self.isFrontCameraSupported = NO;
    } else {
        self.isFrontCameraSupported = YES;
    }
    
    [backCamera lockForConfiguration:nil];
    if ([backCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
        [backCamera setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    
    [backCamera unlockForConfiguration];
    
    _videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:backCamera error:&error];
    if(error){
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:_videoDeviceInput toCaptureSession:captureSession];
        _cameraDevice = _videoDeviceInput.device;
        return success;
    }
}

//Not used in this project, but illustration of how to select a specific camera
- (BOOL)addCameraAtPosition:(AVCaptureDevicePosition)position toCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    AVCaptureDeviceInput *cameraDeviceInput;
    for(AVCaptureDevice *device in devices){
        if(device.position == position){
            cameraDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        }
    }
    
    
    if(!cameraDeviceInput){
        NSLog(@"No capture device found for requested position");
        return NO;
    }
    
    if(error){
        NSLog(@"error configuring camera input: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:cameraDeviceInput toCaptureSession:captureSession];
        _cameraDevice = cameraDeviceInput.device;
        return success;
    }
}

- (BOOL)addDefaultMicInputToCaptureSession:(AVCaptureSession *)captureSession
{
    NSError *error;
    AVCaptureDeviceInput *micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:&error];
    if(error){
        NSLog(@"error configuring mic input: %@", [error localizedDescription]);
        return NO;
    } else {
        BOOL success = [self addInput:micDeviceInput toCaptureSession:captureSession];
        return success;
    }
}

- (BOOL)addInput:(AVCaptureDeviceInput *)input toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddInput:input]){
        [captureSession addInput:input];
        return YES;
    } else {
        NSLog(@"can't add input: %@", [input description]);
    }
    return NO;
}


- (BOOL)addOutput:(AVCaptureOutput *)output toCaptureSession:(AVCaptureSession *)captureSession
{
    if([captureSession canAddOutput:output]){
        [captureSession addOutput:output];
        return YES;
    } else {
        NSLog(@"can't add output: %@", [output description]);
    }
    return NO;
}


#pragma mark - Methods discussed in the article but not used in this demo app

- (void)setFrameRateWithDuration:(CMTime)frameDuration OnCaptureDevice:(AVCaptureDevice *)device
{
    NSError *error;
    NSArray *supportedFrameRateRanges = [device.activeFormat videoSupportedFrameRateRanges];
    BOOL frameRateSupported = NO;
    for(AVFrameRateRange *range in supportedFrameRateRanges){
        if(CMTIME_COMPARE_INLINE(frameDuration, >=, range.minFrameDuration) && CMTIME_COMPARE_INLINE(frameDuration, <=, range.maxFrameDuration)){
            frameRateSupported = YES;
        }
    }
    
    if(frameRateSupported && [device lockForConfiguration:&error]){
        [device setActiveVideoMaxFrameDuration:frameDuration];
        [device setActiveVideoMinFrameDuration:frameDuration];
        [device unlockForConfiguration];
    }
}


- (void)listCamerasAndMics
{
    NSLog(@"%@", [[AVCaptureDevice devices] description]);
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    [audioSession setActive:YES error:&error];
    
    NSArray *availableAudioInputs = [audioSession availableInputs];
    NSLog(@"audio inputs: %@", [availableAudioInputs description]);
    for(AVAudioSessionPortDescription *portDescription in availableAudioInputs){
        NSLog(@"data sources: %@", [[portDescription dataSources] description]);
    }
    if([availableAudioInputs count] > 0){
        AVAudioSessionPortDescription *portDescription = [availableAudioInputs firstObject];
        if([[portDescription dataSources] count] > 0){
            NSError *error;
            AVAudioSessionDataSourceDescription *dataSource = [[portDescription dataSources] lastObject];
            
            [portDescription setPreferredDataSource:dataSource error:&error];
            [self logError:error];
            
            [audioSession setPreferredInput:portDescription error:&error];
            [self logError:error];
            
            NSArray *availableAudioInputs = [audioSession availableInputs];
            NSLog(@"audio inputs: %@", [availableAudioInputs description]);
            
        }
    }
}

- (void)logError:(NSError *)error
{
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
}

- (void)configureFrontMic
{
    NSError *error;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:&error];
    if(error){
        NSLog(@"%@", [error localizedDescription]);
    }
    [audioSession setActive:YES error:&error];
    
    NSArray* inputs = [audioSession availableInputs];
    AVAudioSessionPortDescription *builtInMic = nil;
    for (AVAudioSessionPortDescription* port in inputs){
        if ([port.portType isEqualToString:AVAudioSessionPortBuiltInMic]){
            builtInMic = port;
            break;
        }
    }
    
    for (AVAudioSessionDataSourceDescription* source in builtInMic.dataSources){
        if ([source.orientation isEqual:AVAudioSessionOrientationFront]){
            [builtInMic setPreferredDataSource:source error:nil];
            [audioSession setPreferredInput:builtInMic error:&error];
            break;
        }
    }
}
@end
