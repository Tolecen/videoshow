//
//  XjAVPlayerSDK.m
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XjAVPlayerSDK.h"
#import "XJAVPlyer.h"
#import "XJGestureButton.h"
#import "XJBottomMenu.h"
#import "XJTopMenu.h"
#import "UIView+SCYCategory.h"
#import "UIDevice+XJDevice.h"

#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

@interface XjAVPlayerSDK (){
    BOOL isStop;//是否关闭过播放器（关闭，不是暂停）
}

@property (nonatomic, strong)XJAVPlyer *xjPlayer;
@property (nonatomic, strong)XJGestureButton *backView;
@property (nonatomic, strong)XJTopMenu *topMenu;
@property (nonatomic, strong)XJBottomMenu *bottomMenu;

@property (nonatomic, assign)CGRect firstFrame;//初始化的视屏大小
@property (nonatomic, strong)NSString *saveUrl;//保存url;
@property (nonatomic, strong)NSString *saveTitle;//保存标题

@property (nonatomic, strong) UIActivityIndicatorView *loadingView;//菊花图

@end

@implementation XjAVPlayerSDK

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
        self.firstFrame = frame;
        [self addAllView];
    }
    return self;
}

- (void)addAllView{
    
    [self.backView addSubview:self.topMenu];
    [self.backView addSubview:self.bottomMenu];
    [self.backView addSubview:self.loadingView];
    [self.xjPlayer addSubview:self.backView];
    [self addSubview:self.xjPlayer];
    
}

#pragma mark - **************************** 外部接口 *************************************
- (void)xjStopPlayer{
    [self.xjPlayer xjStop];
}
- (CGFloat)xjCurrentTime{
    return self.xjPlayer.xjCurrentTime;
}
- (CGFloat)xjTotalTime{
    return self.xjPlayer.xjTotalTime;
}
#pragma mark - **************************** xjAVPlayer方法 ************************
- (void)xjAVPlayerBLock{
    WS(weakSelf);
    //加载成功回调
    self.xjPlayer.xjPlaySuccessBlock = ^{
//        weakSelf.bottomMenu.xjPlay = YES;//如果想一进来就播放，就放开注释
        [weakSelf.loadingView stopAnimating];
        [weakSelf.loadingView setHidesWhenStopped:YES];
    };
    //播放失败回调
    self.xjPlayer.xjPlayFailBlock = ^{
        weakSelf->isStop = YES;//保证点击播放按钮能播放
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.loadingView) {
                [weakSelf.loadingView stopAnimating];
                [weakSelf.loadingView setHidesWhenStopped:YES];
            }
        });
    };
    //加载进度
    self.xjPlayer.xjLoadedTimeBlock = ^(CGFloat time){
        weakSelf.bottomMenu.xjLoadedTimeRanges = time;
    };
    //视屏总长
    self.xjPlayer.xjTotalTimeBlock = ^(CGFloat time){
        weakSelf.bottomMenu.xjTotalTime = time;
    };
    //当前时间
    self.xjPlayer.xjCurrentTimeBlock = ^(CGFloat time){
        weakSelf.bottomMenu.xjCurrentTime = time;
    };
    //播放完
    self.xjPlayer.xjPlayEndBlock = ^{
        weakSelf.bottomMenu.xjPlayEnd = YES;
        //下一个
        if ([weakSelf.XjAVPlayerSDKDelegate respondsToSelector:@selector(xjNextPlayer)]) {
            [weakSelf.XjAVPlayerSDKDelegate xjNextPlayer];
        }
    };
    //关闭控件
    self.xjPlayer.xjPlayerStop = ^{
        weakSelf->isStop = YES;
        weakSelf.bottomMenu.xjPlayEnd = YES;
    };
    //方向改变
    self.xjPlayer.xjDirectionChange = ^(UIDeviceOrientation orient){
        if (weakSelf.xjAutoOrient) {
            if (orient == UIDeviceOrientationPortrait) {
                weakSelf.frame = weakSelf.firstFrame;
                weakSelf.bottomMenu.xjFull = NO;
            }else if(orient == UIDeviceOrientationLandscapeLeft||orient == UIDeviceOrientationLandscapeRight){
                weakSelf.frame = weakSelf.window.bounds;
                weakSelf.bottomMenu.xjFull = YES;
            }
        }
    };
    //播放延迟
    self.xjPlayer.xjDelayPlay = ^(BOOL flag){
        if (flag&&!weakSelf->isStop) {
            [weakSelf.loadingView startAnimating];
        }else{
            [weakSelf.loadingView stopAnimating];
            [weakSelf.loadingView setHidesWhenStopped:YES];
        }
    };
}
#pragma mark - **************************** XJGestureButton方法 **********************
- (void)xjGestureButtonBlock{
    WS(weakSelf);
    //单击/双击事件
    self.backView.userTapGestureBlock = ^(NSUInteger number,BOOL flag){
        if (number == 1) {
            [UIView animateWithDuration:0.3 animations:^{
                weakSelf.topMenu.hidden = flag;
                weakSelf.bottomMenu.hidden = flag;
            }];
        }else if (number == 2){
            weakSelf.bottomMenu.xjPlay = flag;//不受flag影响
        }
    };
    //开始触摸
    self.backView.touchesBeganWithPointBlock = ^CGFloat(){
        //返回当前播放进度
        return [weakSelf.xjPlayer xjCurrentRate];
    };
    //结束触摸
    self.backView.touchesEndWithPointBlock = ^(CGFloat rate){
        //进度
        [weakSelf.xjPlayer xjSeekToTimeWithSeconds:[weakSelf.xjPlayer xjTotalTime]*rate];
    };
}
#pragma mark - **************************** XJTopMenu方法 *****************************
- (void)xjTopMenuBlock{
    WS(weakSelf);
    //返回
    self.topMenu.xjTopGoBack = ^{
        if (weakSelf.bottomMenu.xjFull) {
            [UIDevice setOrientation:UIInterfaceOrientationPortrait];
            weakSelf.frame = weakSelf.firstFrame;
            weakSelf.bottomMenu.xjFull = NO;
        }else{
            if ([weakSelf.XjAVPlayerSDKDelegate respondsToSelector:@selector(xjGoBack)]) {
                [weakSelf.XjAVPlayerSDKDelegate xjGoBack];
            }
        }
    };
}
#pragma mark - **************************** XJBottomMenu方法 **************************
- (void)xjBottomMenuBlock{
    WS(weakSelf);
    //播放/暂停
    self.bottomMenu.xjPlayOrPauseBlock = ^(BOOL isPlay){
        if (weakSelf->isStop) {
            weakSelf->isStop = NO;
            weakSelf.xjPlayer.xjPlayerUrl = weakSelf.saveUrl;
            weakSelf.topMenu.xjAvTitle = weakSelf.saveTitle;
        }
        if (isPlay) {
            [weakSelf.xjPlayer xjPlay];
        }else{
            [weakSelf.xjPlayer xjPause];
        }
    };
    //下一个
    self.bottomMenu.xjNextPlayerBlock = ^{
        weakSelf.bottomMenu.xjPlayEnd  = YES;
        if ([weakSelf.XjAVPlayerSDKDelegate respondsToSelector:@selector(xjNextPlayer)]) {
            [weakSelf.XjAVPlayerSDKDelegate xjNextPlayer];
        }
    };
    //滑动条滑动时
    self.bottomMenu.xjSliderValueChangeBlock = ^(CGFloat time){
        [weakSelf.xjPlayer xjSeekToTimeWithSeconds:time];
        [weakSelf.xjPlayer xjPause];
    };
    //滑动条拖动完成
    self.bottomMenu.xjSliderValueChangeEndBlock = ^(CGFloat time){
        [weakSelf.xjPlayer xjSeekToTimeWithSeconds:time];
    };
    //放大/缩小
    self.bottomMenu.xjFullOrSmallBlock = ^(BOOL isFull){
        if (isFull) {
            [UIDevice setOrientation:UIInterfaceOrientationLandscapeRight];
            weakSelf.frame = weakSelf.window.bounds;
            [weakSelf prefersStatusBarHidden];
           
        }else{
            [UIDevice setOrientation:UIInterfaceOrientationPortrait];
            weakSelf.frame = weakSelf.firstFrame;
        }
    };
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark - **************************** 懒加载 ****************************************
- (XJAVPlyer *)xjPlayer{
    if (_xjPlayer == nil) {
        _xjPlayer = [[XJAVPlyer alloc] init];
        [self xjAVPlayerBLock];
    }
    return _xjPlayer;
}

- (void)setXjPlayerUrl:(NSString *)xjPlayerUrl{
    _xjPlayerUrl = xjPlayerUrl;
    self.saveUrl = _xjPlayerUrl;
    self.xjPlayer.xjPlayerUrl = _xjPlayerUrl;
}

- (void)setXjLastTime:(int)xjLastTime{
    _xjLastTime = xjLastTime;
    [self.xjPlayer xjSeekToTimeWithSeconds:_xjLastTime];
}

- (XJGestureButton *)backView{
    if (_backView == nil) {
        _backView = [[XJGestureButton alloc] init];
        [self xjGestureButtonBlock];
    }
    return _backView;
}

- (XJTopMenu *)topMenu{
    if (_topMenu == nil) {
        _topMenu = [[XJTopMenu alloc] init];
        _topMenu.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _topMenu.hidden = YES;
        [self xjTopMenuBlock];
    }
    return _topMenu;
}

- (void)setXjPlayerTitle:(NSString *)xjPlayerTitle{
    _xjPlayerTitle = xjPlayerTitle;
    self.saveTitle = _xjPlayerTitle;
    self.topMenu.xjAvTitle = self.xjPlayerTitle;
}

- (XJBottomMenu *)bottomMenu{
    if (_bottomMenu == nil) {
        _bottomMenu = [[XJBottomMenu alloc] init];
        _bottomMenu.backgroundColor = [UIColor colorWithRed:50.0/255.0 green:50.0/255.0 blue:50.0/255.0 alpha:1.0];
        _bottomMenu.hidden = YES;
        [self xjBottomMenuBlock];
    }
    return _bottomMenu;
}

- (UIActivityIndicatorView *)loadingView{
    if (_loadingView == nil) {
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [_loadingView startAnimating];
    }
    return _loadingView;
}

#pragma mark - **************************** 布局 *************************************
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.xjPlayer.frame = CGRectMake(0, 0, self.width, self.height);
    self.backView.frame = self.xjPlayer.frame;
    self.topMenu.frame = CGRectMake(0, self.backView.top, self.backView.width, 40);
    self.bottomMenu.frame = CGRectMake(0, self.backView.height-40, self.backView.width, 40);
    self.loadingView.center = CGPointMake(self.backView.centerX, self.backView.centerY);
}

@end
