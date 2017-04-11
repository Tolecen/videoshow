//
//  BabyCaptureSessionCoordinatorViewController.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoRecorderViewController.h"
#import "BabyCaptureSessionAssetWriterCoordinator.h"
#import "BabyFileManager.h"
#import "BabyPermissionsManager.h"
#import "ProgressBar.h"
#import "DeleteButton.h"
#import <QuartzCore/QuartzCore.h>
#import "SVProgressHUD.h"
#import "GXCustomButton.h"
#import "MacroDefinition.h"


#import <IJKMediaFramework/VideoEncoder.h>
#import "TZImageManager.h"
#import "TZImagePickerController.h"
//#import "BabyDialog.h"

#import "VideoPreviewViewController.h"
#import "VideoImportImageViewController.h"
#import "VideoImportVideoViewController.h"


#import <MobileCoreServices/MobileCoreServices.h>
#import "UIView+SDAutoLayout.h"

#define TIMER_INTERVAL 0.05f

#define TAG_ALERTVIEW_CLOSE_CONTROLLER 10086

@interface VideoRecorderViewController () <BabyCaptureSessionCoordinatorDelegate, TZImagePickerControllerDelegate, UIAlertViewDelegate,CAAnimationDelegate>
{
   
    UIButton *buttonSelect[5];
    UIButton *buttonSelectTime[5];

}

@property (strong, nonatomic) ProgressBar *progressBar;

@property (strong, nonatomic) DeleteButton *deleteButton;
@property (strong, nonatomic) UIButton *okButton;

@property (strong, nonatomic) UIButton *closeButton;
@property (strong, nonatomic) UIButton *switchButton;
@property (strong, nonatomic) UIButton *settingButton;
@property (strong, nonatomic) UIButton *recordButton;
@property (strong, nonatomic) UIButton *flashButton;

@property (strong, nonatomic) GXCustomButton *videoImportButton;
@property (strong, nonatomic) GXCustomButton *imageImportButton;

@property (assign, nonatomic) BOOL initalized;
@property (assign, nonatomic) BOOL isProcessingData;

@property (strong, nonatomic) UIView *preview;
@property (strong, nonatomic) UIImageView *focusRectView;

@property (nonatomic, strong) BabyCaptureSessionAssetWriterCoordinator *captureSessionCoordinator;

@property (nonatomic, assign) BOOL recording;
@property (nonatomic,assign) BOOL isTimeALL;
@property (nonatomic, assign) BOOL dismissing;

@property (strong, nonatomic) UIView *maskViewTop;
@property (strong, nonatomic) UIView *maskViewBottom;
@property (strong, nonatomic) CALayer *maskHuafuLayer;
@property (strong, nonatomic) CALayer *maskHuafuLayerTop;
@property (strong,nonatomic) UILabel *labelHuafuV;
@property (strong,nonatomic) UILabel *labelShiChangV;
@property(nonatomic, assign) CGFloat outputHeight;
@property (strong, nonatomic) CALayer *maskCircleLayer;

@property (nonatomic,assign)BOOL isCircle;


@property (nonatomic, strong) MediaObject *mMediaObject;

@property (nonatomic, assign) BOOL savedDraft;

@end

@implementation VideoRecorderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
//    self.view.backgroundColor = RGB(244.0f, 48.0f, 125.0f);
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initPreview];
    [self initHuafuBtns];
    [self setOutputDirectory];
    
    
    [self initTopLayout];
    [self initProgressBar];
    [self initRecordButton];
    [self initDeleteButton];
    [self initOKButton];
    [self initVideoImportButton];
    [self initImageImportButton];
    
    _isTimeALL = NO;

}



- (UIView *)getMaskViewTop
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH / 2)];
    maskView.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    return maskView;
}

- (UIView *)getMaskViewBottom
{
    UIView *maskView = [[UIView alloc] initWithFrame:CGRectMake(0, SCREEN_WIDTH / 2, SCREEN_WIDTH, SCREEN_HEIGHT-1.3*SCREEN_WIDTH-45.0f)];
    maskView.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    return maskView;
}

- (void)stopPipelineAndDismiss
{
    [_captureSessionCoordinator stopRunning];
//    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:YES];
    _dismissing = NO;
}

- (void)setOutputDirectory
{
    int64_t date = [[NSDate date] timeIntervalSince1970]*1000*1000;
    int random = arc4random();
    if (random < 0) {
        random = -random;
    }
    NSString *key = [NSString stringWithFormat:@"%lld_%d", date, random];
    DLog(@"key : %@", key);
    
    NSString *tempPath = [BabyFileManager createVideoFolderIfNotExist:key];
    DLog(@"tempPath : %@", tempPath);
    
    self.mMediaObject = [MediaObject initWithKey:key path:tempPath];
    DLog(@"self.mMediaObject max : %d", self.mMediaObject.mMaxDuration);
    
}

- (void)checkPermissions
{
    BabyPermissionsManager *pm = [BabyPermissionsManager new];
    [pm checkCameraAuthorizationStatusWithBlock:^(BOOL granted) {
        if(!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动麦克风"
                                                                message:@"请为萌宝拍打开麦克风权限：手机设置->隐私->麦克风->萌宝拍（打开）"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:@"去设置", nil];
                [alert show];
            });
        }
    }];
    [pm checkMicrophonePermissionsWithBlock:^(BOOL granted) {
        if(!granted){
            dispatch_async(dispatch_get_main_queue(), ^{
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动麦克风"
                                                                message:@"请为萌宝拍打开麦克风权限：手机设置->隐私->麦克风->萌宝拍（打开）"
                                                               delegate:self
                                                      cancelButtonTitle:@"确定"
                                                      otherButtonTitles:@"去设置", nil];
                [alert show];
            });
        }
    }];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self checkPermissions];
    if (_initalized) {
        return;
    }
    
    NSLog(@"viewDidAppear");
    
    [self initRecorder];
    [self hideMaskView];
    [self initHuafuLayer];

    self.initalized = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    if (_captureSessionCoordinator != nil) {
        [_captureSessionCoordinator startRunning];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    
    [_captureSessionCoordinator stopRunning];
}

- (void)initPreview
{
    
    self.preview =  [[UIView alloc] initWithFrame:CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_WIDTH*1.3)];
    _preview.clipsToBounds = YES;
    
    self.maskViewTop = [self getMaskViewTop];
    self.maskViewBottom = [self getMaskViewBottom];
    
    self.maskViewTop.layer.zPosition = 1000;
    self.maskViewBottom.layer.zPosition = 1000;
    
    [_preview addSubview:self.maskViewTop];
    [_preview addSubview:self.maskViewBottom];
    
    [self.view addSubview:_preview];
}

- (void)hideMaskView
{
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.maskViewTop.frame;
        frame.origin.y = -self.maskViewTop.frame.size.height;
        self.maskViewTop.frame = frame;
    }];
    
    [UIView animateWithDuration:0.5f animations:^{
        CGRect frame = self.maskViewBottom.frame;
        frame.origin.y = 1000;
        self.maskViewBottom.frame = frame;
    }completion:^(BOOL finished) {
        _recordButton.enabled = YES;
        [Utils heartbeatView:_recordButton duration:.5f];
    }];
    


}

- (void)initRecorder
{
    NSLog(@"initRecorder");
    _captureSessionCoordinator = [BabyCaptureSessionAssetWriterCoordinator new];
    [_captureSessionCoordinator setDelegate:self callbackQueue:dispatch_get_main_queue()];
    [_captureSessionCoordinator setMediaObject:self.mMediaObject];
    AVCaptureVideoPreviewLayer *previewLayer = [_captureSessionCoordinator previewLayer];
    previewLayer.frame = self.view.bounds;
    previewLayer.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH*1.3);
    [self.preview.layer addSublayer:previewLayer];
    
    _switchButton.enabled = [_captureSessionCoordinator isFrontCameraSupported];
    _flashButton.enabled = [_captureSessionCoordinator isTorchSupported];
    
    [_captureSessionCoordinator startRunning];
}

- (void)initHuafuLayer
{
    
    _outputHeight = 640;
    
    
    CALayer *layer = [[CALayer alloc] init];
    [layer setFrame:CGRectMake(0.0f, self.preview.layer.frame.size.height, self.view.frame.size.width,600.0f)];
    [layer setBackgroundColor:[UIColor blackColor].CGColor];
    [self.preview.layer addSublayer:layer];
    self.maskHuafuLayer =layer;

    
    CALayer *layerTop = [[CALayer alloc] init];
    [layerTop setFrame:CGRectMake(0.0f, self.preview.layer.frame.origin.y, self.view.frame.size.width,0.0f)];
    [layerTop setBackgroundColor:[UIColor blackColor].CGColor];
    [self.preview.layer addSublayer:layerTop];
    self.maskHuafuLayerTop =layerTop;
    
    
    CALayer *layerCircle = [CALayer layer];
    layerCircle.contents = (__bridge id _Nullable)(ImageNamed(@"frame_overlay_black.png")).CGImage;
    self.maskCircleLayer = layerCircle;
    [layerCircle setFrame:CGRectMake(0.0f, 0.0f, self.preview.layer.frame.size.width, self.preview.layer.frame.size.width)];
    [self.preview.layer  addSublayer:layerCircle];
    
    
    layerCircle.hidden = YES;
    
    

}


- (void)initProgressBar
{
    self.progressBar = [[ProgressBar alloc]init];
    [self.view addSubview:_progressBar];
    
    self.progressBar.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(PROGRESSBAR_H)
    .topSpaceToView(self.preview, 0);
    
    [_progressBar startShining];
}

- (void)initDeleteButton
{
    if (_isProcessingData) {
        return;
    }
    
    self.deleteButton = [[DeleteButton alloc]init];
    [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
    [_deleteButton addTarget:self action:@selector(pressDeleteButton) forControlEvents:UIControlEventTouchUpInside];
    _deleteButton.hidden = YES;
    [self.view addSubview:_deleteButton];
    
    _deleteButton.sd_layout
    .widthIs(50)
    .heightIs(50)
    .centerYEqualToView(_recordButton)
    .rightSpaceToView(_recordButton, 50);
    
}


- (void)initHuafuBtns
{
  
    CGFloat buttonW = 80.0f;
    self.recordButton = [[UIButton alloc] init];
    [_recordButton setImage:ImageNamed(@"record_new_cam") forState:UIControlStateNormal];
    [_recordButton setImage:ImageNamed(@"record_new_cam_highlighted") forState:UIControlStateHighlighted];
    _recordButton.userInteractionEnabled = NO;
    _recordButton.enabled = NO;
    [self.view addSubview:_recordButton];
    
    
//    UIView * huafuContentView = [[UIView alloc] init];
//    [self.view addSubview:huafuContentView];
//    [huafuContentView setBackgroundColor:[UIColor whiteColor]];
//    huafuContentView.sd_layout.xIs(0.0f).rightEqualToView(self.view).heightIs(130).bottomSpaceToView(_recordButton,80);
    
    
    UILabel *labelHuafu = [[UILabel alloc] init];
    [labelHuafu setText:@"画幅"];
    [self.view addSubview:labelHuafu];
    labelHuafu.textColor = UIColorFromRGB(BABYCOLOR_record_text_normal);
    labelHuafu.sd_layout.xIs(37.0f).widthIs(buttonW).heightIs(30).bottomSpaceToView(_recordButton,80);
    self.labelHuafuV = labelHuafu;
    
    UILabel *labelShichang = [[UILabel alloc] init];
    [labelShichang setText:@"时长"];
    [self.view addSubview:labelShichang];
    labelShichang.textColor = UIColorFromRGB(BABYCOLOR_record_text_normal);
    labelShichang.sd_layout.xIs(37.0f).widthIs(buttonW).heightIs(30.0f).bottomSpaceToView(_recordButton,20.0f);
    self.labelShiChangV = labelShichang;

  
    
    for (int i=0; i<5; i++) {
        UIButton *selectSender = [UIButton buttonWithType:UIButtonTypeCustom];
        buttonSelect[i] = selectSender;
        NSString *stringImageName = nil;
        if(i==0)
        {
            stringImageName = [NSString stringWithFormat:@"buttonhua%d1",i];
        }else
        {
            stringImageName = [NSString stringWithFormat:@"buttonhua%d0",i];
        }
        [selectSender setImage:ImageNamed(stringImageName) forState:UIControlStateNormal];
        [selectSender addTarget:self action:@selector(selectSenderClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:selectSender];
        selectSender.sd_layout.xIs(i*55.0f+120.0f).centerYEqualToView(labelHuafu).widthIs(25).heightIs(32.5f);
    }
    
    
    UIButton *selectTimeSender = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectTimeSender setTitle:@"9s" forState:UIControlStateNormal];
    [self.view addSubview:selectTimeSender];
    [selectTimeSender addTarget:self action:@selector(selectTimeClick:) forControlEvents:UIControlEventTouchUpInside];
    buttonSelectTime[0] = selectTimeSender;
    selectTimeSender.sd_layout.centerXEqualToView(buttonSelect[0]).centerYEqualToView(labelShichang).widthIs(25).heightIs(32.5f);
    
    
    UIButton *allTimeSender = [UIButton buttonWithType:UIButtonTypeCustom];
    [allTimeSender setTitle:@"任意时长" forState:UIControlStateNormal];
    [allTimeSender setTitleColor:RGB(94.0f, 97.0f, 96.0f) forState:UIControlStateNormal];
    [self.view addSubview:allTimeSender];
    buttonSelectTime[1] = allTimeSender;
    [allTimeSender addTarget:self action:@selector(selectTimeClick:) forControlEvents:UIControlEventTouchUpInside];
    allTimeSender.sd_layout.centerYEqualToView(selectTimeSender).widthIs(80).heightIs(32.5f).leftEqualToView(buttonSelect[1]);
    
    
    _recordButton.sd_layout
    .widthIs(buttonW)
    .heightIs(buttonW)
    .centerXEqualToView(self.view)
    .bottomSpaceToView(self.view, 40);
    
}

- (void)initRecordButton
{
    CGFloat buttonW = 80.0f;
    self.recordButton = [[UIButton alloc] init];
    [_recordButton setImage:ImageNamed(@"record_new_cam") forState:UIControlStateNormal];
    [_recordButton setImage:ImageNamed(@"record_new_cam_highlighted") forState:UIControlStateHighlighted];
    _recordButton.userInteractionEnabled = NO;
    _recordButton.enabled = NO;
    [self.view addSubview:_recordButton];
    
    _recordButton.sd_layout
    .widthIs(buttonW)
    .heightIs(buttonW)
    .centerXEqualToView(self.view)
    .bottomSpaceToView(self.view, 40);
}

- (void)initOKButton
{
    CGFloat okButtonW = 25.0f;
    self.okButton = [[UIButton alloc] init];
    _okButton.enabled = NO;
    
    [_okButton setImage:ImageNamed(@"record_undo_right") forState:UIControlStateNormal];
    [_okButton setImage:ImageNamed(@"record_undo_right") forState:UIControlStateHighlighted];
    _okButton.hidden = YES;
    [_okButton addTarget:self action:@selector(pressOKButton) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:_okButton];
    
    _okButton.sd_layout
    .widthIs(30.0f)
    .heightIs(20.0f)
    .centerYEqualToView(_recordButton)
    .leftSpaceToView(_recordButton, 50);
}

- (void)initVideoImportButton
{
    _videoImportButton = [GXCustomButton buttonWithType:UIButtonTypeCustom];
    
    [_videoImportButton setImage:ImageNamed(@"record_new_video") forState:UIControlStateNormal];
    [_videoImportButton setImage:ImageNamed(@"record_new_video_highlighted") forState:UIControlStateDisabled];
    [_videoImportButton setTitle:@"导入视频" forState:UIControlStateNormal];
    
    
    [_videoImportButton setTitleColor:UIColorFromRGB(BABYCOLOR_record_text_normal) forState:UIControlStateNormal];
    [_videoImportButton setTitleColor:UIColorFromRGB(BABYCOLOR_record_text_pressed) forState:UIControlStateHighlighted];
    [_videoImportButton addTarget:self action:@selector(pressVideoImportButton) forControlEvents:UIControlEventTouchUpInside];
    
    _videoImportButton.imageView.contentMode = UIViewContentModeCenter; // 让图片在按钮内居中
    _videoImportButton.titleLabel.textAlignment = NSTextAlignmentCenter; // 让标题在按钮内居中
    _videoImportButton.titleLabel.font = kFontSizeNormal;// 设置标题的字体大小
    _videoImportButton.userInteractionEnabled = YES;
    _videoImportButton.hidden = NO;
    [self.view addSubview:_videoImportButton];
    
    _videoImportButton.sd_layout
    .widthIs(80)
    .heightIs(80)
    .centerYEqualToView(_recordButton)
    .leftSpaceToView(_recordButton, 40);
}

- (void)initImageImportButton
{
    _imageImportButton = [GXCustomButton buttonWithType:UIButtonTypeCustom];
    
    [_imageImportButton setImage:ImageNamed(@"record_new_pic") forState:UIControlStateNormal];
    [_imageImportButton setImage:ImageNamed(@"record_new_pic_highlighted") forState:UIControlStateDisabled];
    [_imageImportButton setTitle:@"导入照片" forState:UIControlStateNormal];
    
    
    [_imageImportButton setTitleColor:UIColorFromRGB(BABYCOLOR_record_text_normal) forState:UIControlStateNormal];
    [_imageImportButton setTitleColor:UIColorFromRGB(BABYCOLOR_record_text_pressed) forState:UIControlStateHighlighted];
    [_imageImportButton addTarget:self action:@selector(pressImageImportButton) forControlEvents:UIControlEventTouchUpInside];
    
    _imageImportButton.imageView.contentMode = UIViewContentModeCenter; // 让图片在按钮内居中
    _imageImportButton.titleLabel.textAlignment = NSTextAlignmentCenter; // 让标题在按钮内居中
    _imageImportButton.titleLabel.font = kFontSizeNormal;// 设置标题的字体大小
    _imageImportButton.userInteractionEnabled = YES;
    _imageImportButton.hidden = NO;
    [self.view addSubview:_imageImportButton];
    
    _imageImportButton.sd_layout
    .widthIs(80)
    .heightIs(80)
    .centerYEqualToView(_recordButton)
    .rightSpaceToView(_recordButton, 40);
}

- (void)initTopLayout
{
    
    
    UIView *colorBack = [[UIView alloc] init];
    [colorBack setBackgroundColor:RGB(244.0f, 48.0f, 125.0f)];
    [self.view addSubview:colorBack];
    colorBack.sd_layout.xIs(0).yIs(0).widthIs(self.view.width).heightIs(64.0f);

    
    
    CGFloat buttonW = 36.0f;
    
    //关闭
    self.closeButton = [[UIButton alloc] init];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateNormal];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateDisabled];
//    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateSelected];
//    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.layer.zPosition = 1001;
    [self.view addSubview:_closeButton];
    
    
    _closeButton.sd_layout
    .widthIs(buttonW)
    .heightIs(buttonW)
    .topSpaceToView(self.view, 23)
    .leftSpaceToView(self.view, 10);
    
    

    //前后摄像头转换
    self.switchButton = [[UIButton alloc] init];
    [_switchButton setImage:ImageNamed(@"record_camera_switch_normal") forState:UIControlStateNormal];
    [_switchButton setImage:ImageNamed(@"record_camera_switch_disable") forState:UIControlStateDisabled];
    [_switchButton setImage:ImageNamed(@"record_camera_switch_normal") forState:UIControlStateSelected];
    [_switchButton setImage:ImageNamed(@"record_camera_switch_pressed") forState:UIControlStateHighlighted];
    [_switchButton addTarget:self action:@selector(pressSwitchButton) forControlEvents:UIControlEventTouchUpInside];
    _switchButton.layer.zPosition = 1001;
    [self.view addSubview:_switchButton];
    
    
    _switchButton.sd_layout
    .widthIs(buttonW-6.0f)
    .heightIs(buttonW-12.0f)
    .topSpaceToView(self.view, 27)
    .centerXEqualToView(self.view);
    
    
    self.flashButton = [[UIButton alloc] init];
    [_flashButton setImage:ImageNamed(@"record_camera_flash_led_off_normal") forState:UIControlStateNormal];
    [_flashButton setImage:ImageNamed(@"record_camera_flash_led_off_normal") forState:UIControlStateDisabled];
    [_flashButton setImage:ImageNamed(@"record_camera_flash_led_off_pressed") forState:UIControlStateHighlighted];
    [_flashButton setImage:ImageNamed(@"record_camera_flash_led_on_normal") forState:UIControlStateSelected];
    _flashButton.hidden = YES;
    
    _flashButton.layer.zPosition = 1001;
    [_flashButton addTarget:self action:@selector(pressFlashButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_flashButton];
    
    _flashButton.sd_layout
    .widthIs(buttonW)
    .heightIs(buttonW)
    .topSpaceToView(self.view, 10)
    .rightSpaceToView(_switchButton, 20);
    
    //focus rect view
    self.focusRectView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
    _focusRectView.layer.zPosition = 1001;
    _focusRectView.image = ImageNamed(@"record_focus");
    _focusRectView.alpha = 0;
    [self.preview addSubview:_focusRectView];
    
}

- (void)pressVideoImportButton
{
//    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
//    // 设置是否可以选择视频/图片
//    imagePickerVc.allowPickingVideo = YES;
//    imagePickerVc.allowPickingImage = NO;
//    
//    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
    //UIImagePickerController相册选择视频
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //资源类型为视频库
    
    NSString *requiredMediaType1 = (NSString *)kUTTypeMovie;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum
    
    NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType1,nil];
    
    [picker setMediaTypes: arrMediaTypes];
    
    picker.delegate = (id)self;
    
    [[picker navigationBar] setBarTintColor:[AppAppearance sharedAppearance].mainColor];
    [[picker navigationBar] setTintColor:[UIColor whiteColor]];
    [[picker navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void)pressImageImportButton
{

    VideoImportImageViewController *imagePickerVc = [[VideoImportImageViewController alloc]init];
    imagePickerVc.tag = _tag;
    imagePickerVc.tag_id = _tag_id;
    
    imagePickerVc.onPublish = ^() {
        [self stopPipelineAndDismiss];
    };
    [self.navigationController pushViewController:imagePickerVc animated:YES];
    
}

- (void)pushToVideoImport:(NSURL *)filePath
{
    VideoImportVideoViewController *videoImportVc = [[VideoImportVideoViewController alloc]init];
    videoImportVc.tag = _tag;
    videoImportVc.tag_id = _tag_id;
    videoImportVc.videoPath = filePath;
    videoImportVc.onPublish = ^() {
        [self stopPipelineAndDismiss];
    };
    [self.navigationController pushViewController:videoImportVc animated:YES];
}

- (void)pressCloseButton
{
    
    NSLog(@"pressCloseButton------");
//    if ([_captureSessionCoordinator getVideoCount] > 0) {
//        [self closeDialog];
//    } else {
        if(_recording){
            _dismissing = YES;
            [_captureSessionCoordinator stopRecording];
        } else {
            [_captureSessionCoordinator deleteAllVideo];
            [self stopPipelineAndDismiss];
        }
        
//    }
    
    

    
}



- (void)closeDialog
{
    
    
}

//放弃本次视频，并且关闭页面
- (void)dropTheVideo
{
    
    
    if (!_savedDraft) {
        [_captureSessionCoordinator deleteAllVideo];
    }
    
    [self stopPipelineAndDismiss];
    
    
    
}

- (void)pressSwitchButton
{
    DLog(@"pressSwitchButton------");
    _switchButton.selected = !_switchButton.selected;
    if (_switchButton.selected) {//换成前摄像头
        if (_flashButton.selected) {
            [_captureSessionCoordinator openTorch:NO];
            _flashButton.selected = NO;
            _flashButton.enabled = NO;
        } else {
            _flashButton.enabled = NO;
        }
    } else {
        _flashButton.enabled = [_captureSessionCoordinator isFrontCameraSupported];
    }
    
    [_captureSessionCoordinator switchCamera];
}

- (void)pressFlashButton
{
    _flashButton.selected = !_flashButton.selected;
    [_captureSessionCoordinator openTorch:_flashButton.selected];
}

- (void)pressDeleteButton
{
    if (self.isProcessingData || self.recording) {
        return;
    }
    if (_deleteButton.style == DeleteButtonStyleNormal) {//第一次按下删除按钮
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleDelete];
        [_deleteButton setButtonStyle:DeleteButtonStyleDelete];
    } else if (_deleteButton.style == DeleteButtonStyleDelete) {//第二次按下删除按钮
        [self deleteLastVideo];
        [_progressBar deleteLastProgress];
        
        if ([_captureSessionCoordinator getVideoCount] > 0) {
            [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        } else {
            [_deleteButton setButtonStyle:DeleteButtonStyleDisable];
            [self showHuafuBtns];
        }
    }
}

- (void)pressOKButton
{
    DLog(@"pressOKButton---1");
    if (self.isProcessingData || self.recording) {
        return;
    }
    DLog(@"pressOKButton---");
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD showWithStatus:@"努力处理中"];

    [_captureSessionCoordinator mergeVideoFiles];
    self.isProcessingData = YES;
}

//删除最后一段视频
- (void)deleteLastVideo
{
    if ([_captureSessionCoordinator getVideoCount] > 0) {
        [_captureSessionCoordinator deleteLastVideo];
    }
}

- (void)showFocusRectAtPoint:(CGPoint)point
{
    _focusRectView.alpha = 1.0f;
    _focusRectView.center = point;
    _focusRectView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.2f animations:^{
        _focusRectView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    } completion:^(BOOL finished) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
        animation.values = @[@0.5f, @1.0f, @0.5f, @1.0f, @0.5f, @1.0f];
        animation.duration = 0.5f;
        [_focusRectView.layer addAnimation:animation forKey:@"opacity"];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.3f animations:^{
                _focusRectView.alpha = 0;
            }];
        });
    }];
}

- (void)refreshButtons:(BOOL)hidden
{
    _videoImportButton.hidden = hidden;
    _imageImportButton.hidden = hidden;
    _deleteButton.hidden = !hidden;
    _okButton.hidden = !hidden;
}

#pragma mark - SBBabyCaptureSessionCoordinatorDelegate
- (void)coordinator:(BabyCaptureSessionCoordinator *)videoRecorder didStartRecordingToOutPutFileAtURL:(NSString *)fileURL mediaObject:(MediaObject *)mediaObject
{
    _recording = YES;
    NSLog(@"正在录制视频: %@", fileURL);
    self.mMediaObject = mediaObject;
    _recordButton.enabled = YES;
    [self.progressBar addProgressView];
    [_progressBar stopShining];
    [self refreshButtons:YES];
    [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
}

- (void)coordinator:(BabyCaptureSessionCoordinator *)videoRecorder didFinishRecordingToOutPutFileAtURL:(NSString *)outputFileURL duration:(int)videoDuration totalDur:(int)totalDur mediaObject:(MediaObject *)mediaObject error:(NSError *)error
{
    if (error) {
        NSLog(@"录制视频错误:%@", error);
    } else {
        NSLog(@"录制视频完成: %@", outputFileURL);
    }
    self.mMediaObject = mediaObject;
    [_progressBar startShining];
    
    if (totalDur >= self.mMediaObject.mMaxDuration) {
        [self pressOKButton];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    
    _recording = NO;
    
    //Dismiss camera (when user taps cancel while camera is recording)
    if(_dismissing){
        [self stopPipelineAndDismiss];
    }
    
}

- (void)coordinator:(BabyCaptureSessionCoordinator *)videoRecorder didRemoveVideoFileAtURL:(NSURL *)fileURL totalDur:(CGFloat)totalDur mediaObject:(MediaObject *)mediaObject error:(NSError *)error
{
    if (error) {
        NSLog(@"删除视频错误: %@", error);
    } else {
        NSLog(@"删除了视频: %@", fileURL);
        NSLog(@"现在视频长度: %f", totalDur);
    }
    self.mMediaObject = mediaObject;
    if ([_captureSessionCoordinator getVideoCount] > 0) {
        [self refreshButtons:YES];
        [_deleteButton setStyle:DeleteButtonStyleNormal];
    } else {
        [self refreshButtons:NO];
        [_deleteButton setStyle:DeleteButtonStyleDisable];
    }
    if (_isTimeALL) {
        _okButton.enabled = YES;
//        _progressBar.intervalView.hidden = YES;

        
    }else
    {
        _okButton.enabled = (totalDur >= self.mMediaObject.mMinDuration);
//        _progressBar.intervalView.hidden = NO;

    }
}

- (void)coordinator:(BabyCaptureSessionCoordinator *)videoRecorder didRecordingToOutPutFileAtURL:(NSString *)outputFileURL duration:(int)videoDuration recordedVideosTotalDur:(int)totalDur mediaObject:(MediaObject *)mediaObject
{
    self.mMediaObject = mediaObject;
  
    if (_isTimeALL) {
        _okButton.enabled = YES;
        [_progressBar setLastProgressToWidth:videoDuration * 1.0 / (10000*60) * _progressBar.frame.size.width];
//        _progressBar.intervalView.hidden = YES;

    }else
    {
//        _progressBar.intervalView.hidden = NO;
        _okButton.enabled = (totalDur >= self.mMediaObject.mMinDuration);
        [_progressBar setLastProgressToWidth:videoDuration * 1.0 / self.mMediaObject.mMaxDuration * _progressBar.frame.size.width];

    }

}

- (void)coordinator:(BabyCaptureSessionCoordinator *)videoRecorder didFinishMergingVideosToOutPutFileAtURL:(NSString *)outputFileURL mediaObject:(MediaObject *)mediaObject
{
    
    DLog(@"outputFileURL : %@",outputFileURL);
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.isProcessingData = NO;
        [SVProgressHUD dismiss];
        self.mMediaObject = mediaObject;
        VideoPreviewViewController *player = [[VideoPreviewViewController alloc]initWithMediaObject:self.mMediaObject];
        player.tag = _tag;
        player.tag_id = _tag_id;
        player.fromDraft = NO;
        player.outputHeight = _outputHeight;
        player.isCircle = self.isCircle;
        
        player.savedDraft = ^(BOOL saved) {
            _savedDraft = saved;
        };
        
        player.onPublish = ^() {
            [self stopPipelineAndDismiss];
        };
        
        [self.navigationController pushViewController:player animated:YES];
        
    });
    
//Do something useful with the video file available at the outputFileURL
//    BabyFileManager *fm = [BabyFileManager new];
//    [fm copyFileToCameraRoll:[NSURL fileURLWithPath:outputFileURL]];
    
}

#pragma mark - Touch Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData || !_initalized) {
        return;
    }
    
    if (_deleteButton.style == DeleteButtonStyleDelete) {//取消删除
        [_deleteButton setButtonStyle:DeleteButtonStyleNormal];
        [_progressBar setLastProgressToStyle:ProgressBarProgressStyleNormal];
        return;
    }
    
    UITouch *touch = [touches anyObject];
    
    CGPoint touchPoint = [touch locationInView:_recordButton.superview];
    if (CGRectContainsPoint(_recordButton.frame, touchPoint)) {
        // Disable the idle timer while recording
        [UIApplication sharedApplication].idleTimerDisabled = YES;
        
        self.captureSessionCoordinator.outputHeight = (int)_outputHeight;
        self.captureSessionCoordinator.isCircle = self.isCircle;
        [self.captureSessionCoordinator startRecording];
        
        [self hiddenHuafuBtns];
        
    }
    
    touchPoint = [touch locationInView:self.view];//previewLayer 的 superLayer所在的view
    if (CGRectContainsPoint(_captureSessionCoordinator.previewLayer.frame, touchPoint)) {
        if (touchPoint.y<SCREEN_WIDTH) {
            [self showFocusRectAtPoint:touchPoint];
        }
        [_captureSessionCoordinator focusInPoint:touchPoint];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_isProcessingData) {
        return;
    }
    
    [_captureSessionCoordinator stopRecording];
}


#pragma mark TZImagePickerControllerDelegate



// 用户选择好了图片，如果assets非空，则用户选择了原图。
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingPhotos:(NSArray *)photos sourceAssets:(NSArray *)assets {

    for (id asset in assets) {
        
        [[TZImageManager manager] copyFileFromAsset:asset Complete:^(NSString *filePath, NSString *fileName) {
            NSLog(@"filePath ----------- : %@", filePath);
            NSLog(@"fileName ----------- : %@", fileName);
        }];
    }
    
}

// 用户选择好了视频
- (void)imagePickerController:(TZImagePickerController *)picker didFinishPickingVideo:(UIImage *)coverImage sourceAssets:(id)asset {
    DLogE(@"imagePickerController");
//    __block VideoRecorderViewController *wSelf = self;
    [[TZImageManager manager] copyFileFromAsset:asset Complete:^(NSString *filePath, NSString *fileName) {
        NSLog(@"filePath ----------- : %@", filePath);
        NSLog(@"fileName ----------- : %@", fileName);
//        [wSelf pushToVideoImport:filePath];
    }];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"found a video ： %@", videoURL);
        [self pushToVideoImport:videoURL];
    }
}

// 取消图片选择调用此方法
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // dismiss UIImagePickerController
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == 1){
        NSString *app_id = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
        NSURL *setUrl = [NSURL URLWithString:[NSString stringWithFormat: @"prefs:root=%@", app_id ]];
        [[UIApplication sharedApplication] openURL:setUrl];
    }
}
-(void)setMaskHuafuHide:(BOOL)bValue
{
    
    self.maskHuafuLayer.hidden = bValue;
    self.maskHuafuLayerTop.hidden = bValue;
    
    self.maskCircleLayer.hidden = !bValue;
    if(bValue)
    {
        self.maskHuafuLayer.hidden = NO;
        
        CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"position"];
        animation.fromValue =  [NSValue valueWithCGPoint:self.maskHuafuLayer.position];
        CGPoint toPoint = self.maskHuafuLayer.position;
        toPoint.y = SCREEN_WIDTH;
        animation.toValue = [NSValue valueWithCGPoint:toPoint];
        animation.delegate = self;
        [self.maskHuafuLayer addAnimation:animation forKey:@"selectHuafu"];
        [self.maskHuafuLayer setFrame:CGRectMake(0.0f,toPoint.y, self.view.frame.size.width,self.maskHuafuLayer.frame.size.height)];

    }
    
//    self.maskHuafuLayer.hidden = YES;
//    self.maskHuafuLayerTop.hidden = YES;
//    self.maskCircleLayer.hidden = YES;
    
}
#pragma mark select huafu
-(void)selectSenderClick:(UIButton *)sender
{
    for (int i=0; i<5; i++) {
        if (sender==buttonSelect[i]) {
            NSString *stringImageName = [NSString stringWithFormat:@"buttonhua%d1",i];
            [buttonSelect[i] setImage:ImageNamed(stringImageName) forState:UIControlStateNormal];
            if (i!=4) {
                [self setMaskHuafuHide:NO];
            }
            switch (i) {
                case 0:
                    [self changeMaskHuafu:640];

                    break;
                case 1:
                {
                    [self changeMaskHuafu:480];
                    self.isCircle = NO;
                }
                    break;
                case 2:
                {
                    [self changeMaskHuafu:360];
                    self.isCircle = NO;
                }
                    break;
                case 3:
                {
                    [self changeMaskHuafu:240];
                    self.isCircle = NO;
                }
                    break;
                case 4:
                {
                    [self changeMaskHuafu:480];
                    [self setMaskHuafuHide:YES];
                    self.isCircle = YES;
                }
                    
                    break;
                default:
                    break;
            }
            


        }else
        {
            NSString *stringImageName = [NSString stringWithFormat:@"buttonhua%d0",i];
            [buttonSelect[i] setImage:ImageNamed(stringImageName) forState:UIControlStateNormal];
        }
    }
}

//代理方法
- (void)animationDidStart:(CAAnimation *)anim{
    NSLog(@"START");
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    
    //如果不通过动画事务将隐式动画关闭，会出现动画运行完毕后会从起点突变到终点。
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
//    self.maskHuafuLayer.position = [[anim valueForKey:@"KPOINT"] CGPointValue];
//    [CATransaction commit];
    
}

-(void)selectTimeClick:(UIButton *)sender
{
        if (sender==buttonSelectTime[0]) {
            
            [buttonSelectTime[0] setTitleColor:RGB(255.0f, 255.0f, 255.0f) forState:UIControlStateNormal];
            [buttonSelectTime[1] setTitleColor:RGB(94.0f, 97.0f, 96.0f) forState:UIControlStateNormal];
            _isTimeALL = NO;
            
            _progressBar.intervalView.hidden = NO;

        }else
        {
            [buttonSelectTime[1] setTitleColor:RGB(255.0f, 255.0f, 255.0f) forState:UIControlStateNormal];
            [buttonSelectTime[0] setTitleColor:RGB(94.0f, 97.0f, 96.0f) forState:UIControlStateNormal];
            _isTimeALL = YES;
            _progressBar.intervalView.hidden = YES;

        }
}

-(void)changeMaskHuafu:(CGFloat)posY
{
    
    
    
    float originY = SCREEN_WIDTH*1.3;
    float cHeight = SCREEN_WIDTH * posY/480.f;
    float pH = (originY-cHeight)/2;
    
    _outputHeight = posY;
    
    
    CABasicAnimation *animation  = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue =  [NSValue valueWithCGPoint:self.maskHuafuLayer.position];
    CGPoint toPoint = self.maskHuafuLayer.position;
    toPoint.y = pH+cHeight;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.delegate = self;
    [self.maskHuafuLayer addAnimation:animation forKey:@"selectHuafu"];
    [self.maskHuafuLayer setFrame:CGRectMake(0.0f,pH+cHeight, self.view.frame.size.width,self.maskHuafuLayer.frame.size.height)];
    
    
    
    CABasicAnimation *animationHeight  = [CABasicAnimation animationWithKeyPath:@"size"];
    animationHeight.fromValue =  [NSValue valueWithCGPoint:self.maskHuafuLayerTop.position];
    CGSize toSize = self.maskHuafuLayerTop.frame.size;
    toSize.height = pH;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.delegate = self;
    [self.maskHuafuLayerTop addAnimation:animation forKey:@"selectHuafuSize"];
    [self.maskHuafuLayerTop setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width,pH)];
    
    
//    CABasicAnimation *boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
//    boundsAnimation.fromValue = [NSValue valueWithCGRect:CGRectMake(0.0f, self.preview.layer.frame.size.height, self.view.frame.size.width,0.f)];
//    boundsAnimation.toValue = [NSValue valueWithCGRect:CGRectMake(0.0f,260, self.view.frame.size.width,self.preview.layer.frame.size.height-260.0f)];
//
//    [self.maskHuafuLayer addAnimation:boundsAnimation forKey:@"selectHuafu"];
//
//    [self.maskHuafuLayer setFrame:CGRectMake(0.0f, 260, self.view.frame.size.width,self.preview.layer.frame.size.height-260.0f)];
    
}

-(void)hiddenHuafuBtns
{
    for (int i=0; i<5; i++) {
        buttonSelect[i].hidden = YES;
    }
    buttonSelectTime[0].hidden = YES;
    buttonSelectTime[1].hidden = YES;
    self.labelHuafuV.hidden = YES;
    self.labelShiChangV.hidden = YES;
    
}
-(void)showHuafuBtns
{
    for (int i=0; i<5; i++) {
        buttonSelect[i].hidden = NO;
    }
    buttonSelectTime[0].hidden = NO;
    buttonSelectTime[1].hidden = NO;
    self.labelHuafuV.hidden = NO;
    self.labelShiChangV.hidden = NO;
}


@end
