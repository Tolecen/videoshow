//
//  LZ_PlayerViewController.m
//  AVFoundation_Test
//
//  Created by gutou on 2017/3/12.
//  Copyright © 2017年 gutou. All rights reserved.
//

#import "LZ_PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "BaseNavigationController.h"

@interface LZ_PlayerViewController ()

@property (nonatomic, strong) AVPlayer *avplayer;
@property (nonatomic, strong) AVPlayerItem *avplayerItem;
@property (nonatomic, strong) AVPlayerLayer *avplayerLayer;


//布局
@property (nonatomic, strong) UIButton *playAndPauseBtn;
@property (nonatomic, strong) UISlider *progressSlider;
@property (nonatomic, strong) UILabel *durationLab;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) UIView *backgroudView;


@property (nonatomic, strong) UIActivityIndicatorView *activityView;


@end

#define Screen_Width ([UIScreen mainScreen].bounds.size.height)
#define Screen_Height ([UIScreen mainScreen].bounds.size.width)

@implementation LZ_PlayerViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.avplayerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
}

- (BOOL) shouldAutorotate
{
    return NO;
}

//支持右横屏
- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIView *) backgroudView
{
    if (!_backgroudView) {
        _backgroudView = [UIView new];
        _backgroudView.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        _backgroudView.backgroundColor = [UIColor clearColor];
    }
    return _backgroudView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor blackColor];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [[UIApplication sharedApplication].keyWindow addSubview:self.backgroudView];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.frame = CGRectMake(0, 0, 100, 100);
    self.activityView.center = self.backgroudView.center;
    [self.activityView setHidesWhenStopped:YES];
    [self.view addSubview:self.activityView];
    [self.activityView startAnimating];
    
    [self setupView];
    [self setupTapGes];
    
//    lz_avPlayer_landspace *p = [[lz_avPlayer_landspace alloc]initWithFrame:CGRectMake(0, 0, MainScreenSize.width, MainScreenSize.height) WithUrl:self.playerUrl];
//    [self.view addSubview:p];
}

- (void)deviceOrientationDidChange
{
    if([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait) {
        NSLog(@"当前竖屏");
//        [self orientationChange:NO];
    } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
        NSLog(@"当前横屏");
//        [self orientationChange:YES];
    }
}

- (void)orientationChange:(BOOL)landscapeRight
{
    if (landscapeRight) {
        [UIView animateWithDuration:0.4f animations:^{
            
            self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
            self.view.bounds = CGRectMake(0, 0, Screen_Width, Screen_Height);
        }];
    } else {
        [UIView animateWithDuration:0.4f animations:^{
            self.view.transform = CGAffineTransformMakeRotation(0);
            self.view.bounds = CGRectMake(0, 0, Screen_Width, Screen_Height);
        }];
    }
}

- (void) setupView
{
    self.playAndPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.playAndPauseBtn setImage:nil forState:UIControlStateNormal];
    [self.playAndPauseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playAndPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.playAndPauseBtn addTarget:self action:@selector(allPlayerOrPause) forControlEvents:UIControlEventTouchUpInside];
    self.playAndPauseBtn.frame = CGRectMake(0, Screen_Height - 30, 60, 30);
    [self.backgroudView addSubview:self.playAndPauseBtn];
    
    self.progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.playAndPauseBtn.frame), CGRectGetMinY(self.playAndPauseBtn.frame), Screen_Width-80-CGRectGetMaxX(self.playAndPauseBtn.frame), CGRectGetHeight(self.playAndPauseBtn.frame))];
    [self.progressSlider addTarget:self action:@selector(sliderAction:) forControlEvents:UIControlEventValueChanged];
    self.progressSlider.value = 0;
    self.progressSlider.minimumValue = 0;
    self.progressSlider.maximumValue = 1;
    [self.backgroudView addSubview:self.progressSlider];
    
    self.durationLab = [UILabel new];
    self.durationLab.textColor = [UIColor whiteColor];
    self.durationLab.font = [UIFont systemFontOfSize:12];
    self.durationLab.textAlignment = NSTextAlignmentCenter;
    self.durationLab.text = @"0.00";
    self.durationLab.frame = CGRectMake(CGRectGetMaxX(self.progressSlider.frame), CGRectGetMinY(self.progressSlider.frame), 80, CGRectGetHeight(self.progressSlider.frame));
    [self.backgroudView addSubview:self.durationLab];
    
    self.closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeBtn setImage:nil forState:UIControlStateNormal];
    [self.closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
    [self.closeBtn setTitleColor:self.playAndPauseBtn.currentTitleColor forState:UIControlStateNormal];
    self.closeBtn.frame = CGRectMake(0, 0, 50, 44);
    [self.closeBtn addTarget:self action:@selector(dismissVC) forControlEvents:UIControlEventTouchUpInside];
    [self.backgroudView addSubview:self.closeBtn];
}

- (void) setPlayerUrl:(NSURL *)playerUrl
{
    if (!playerUrl) {
        [self dismissVC];
        NSLog(@"没有网址");
    }else {
        _playerUrl = playerUrl;
        
        self.avplayerItem = [AVPlayerItem playerItemWithURL:playerUrl];
        
        [self.avplayerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        
        self.avplayer = [AVPlayer playerWithPlayerItem:self.avplayerItem];
        self.avplayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avplayer];
        self.avplayerLayer.frame = CGRectMake(0, 0, Screen_Width, Screen_Height);
        self.avplayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        self.progressSlider.maximumValue = CMTimeGetSeconds(self.avplayerItem.duration);
        
        [self.view.layer addSublayer:self.avplayerLayer];
        
        __weak typeof(self) weakSelf = self;
        [self.avplayer addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
            
            CGFloat currentTime = CMTimeGetSeconds(weakSelf.avplayerItem.currentTime);
            CGFloat durationTime = CMTimeGetSeconds(weakSelf.avplayerItem.duration);
            weakSelf.durationLab.text = [NSString stringWithFormat:@"%.1f/%.0f",currentTime,durationTime];
            [weakSelf.progressSlider setValue:currentTime/durationTime animated:YES];
        }];
    }
}

- (void) sliderAction:(UISlider *)slider
{
    [self playAndPauseBtn];
    
    [self.avplayer seekToTime:CMTimeMake(slider.value * CMTimeGetSeconds(self.avplayerItem.duration), 1)];
//    self.avplayerItem.currentTime = slider.value * CMTimeGetSeconds(weakSelf.avplayerItem.duration);
//    NSLog(@"slider.value == %.2f",slider.value);
}

- (void) allPlayerOrPause
{
    if (self.avplayer.timeControlStatus == AVPlayerTimeControlStatusPaused) {
       
        [self.avplayer play];
        [self.playAndPauseBtn setTitle:@"播放" forState:UIControlStateNormal];
        self.backgroudView.hidden = YES;
    }else if (self.avplayer.timeControlStatus == AVPlayerTimeControlStatusPlaying) {
        
        [self.avplayer pause];
        [self.playAndPauseBtn setTitle:@"暂停" forState:UIControlStateNormal];
        self.backgroudView.hidden = NO;
    }else {
        [SVProgressHUD showErrorWithStatus:@"播放错误"];
    }
}

- (void) dismissVC
{
    [self.backgroudView removeFromSuperview];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void) setupTapGes
{
    [UIApplication sharedApplication].keyWindow.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap_1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_1_Action:)];
    [tap_1 setNumberOfTapsRequired:1];
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tap_1];
    
    UITapGestureRecognizer *tap_2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap_2_Action:)];
    [tap_2 setNumberOfTapsRequired:2];
    [[UIApplication sharedApplication].keyWindow addGestureRecognizer:tap_2];
    
    [tap_1 requireGestureRecognizerToFail:tap_2];
}
- (void) tap_1_Action:(UITapGestureRecognizer *)tapGes
{
    self.backgroudView.hidden = !self.backgroudView.hidden;
}
- (void) tap_2_Action:(UITapGestureRecognizer *)tapGes
{
    [self allPlayerOrPause];
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        [self.activityView stopAnimating];
    }
}


@end
