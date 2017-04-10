//
//  XJBottomMenu.m
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XJBottomMenu.h"
#import "UIView+SCYCategory.h"

@interface XJBottomMenu (){
    BOOL isPlay;
    BOOL isHour;
}
@property (nonatomic, strong)UIButton *playOrPauseBtn;//播放/暂停
@property (nonatomic, strong) UIButton *nextPlayerBtn;//下一个视屏（全屏时有）
@property (nonatomic, strong) UIProgressView *loadProgressView;//缓冲进度条
@property (nonatomic, strong) UISlider *playSlider;//播放滑动条
@property (nonatomic, strong) UILabel *timeLabel;//时间标签
@property (nonatomic, strong) UIButton *fullOrSmallBtn;//放大/缩小按钮

@end

@implementation XJBottomMenu

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addAllView];
    }
    return self;
}

- (void)addAllView{
    [self addSubview:self.playOrPauseBtn];
//    [self addSubview:self.nextPlayerBtn];
    [self addSubview:self.loadProgressView];
    [self addSubview:self.playSlider];
    [self addSubview:self.timeLabel];
//    [self addSubview:self.fullOrSmallBtn];
}

#pragma mark - **************************** 控件事件 ***********************************
//开始/暂停
- (void)playOrPauseAction{
    if (isPlay) {
        isPlay = NO;
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }else{
        isPlay = YES;
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    if (self.xjPlayOrPauseBlock) {
        self.xjPlayOrPauseBlock(isPlay);
    }
}

//下一个
- (void)nextPlayerAction{
    if (self.xjNextPlayerBlock) {
        self.xjNextPlayerBlock();
    }
}

//已加载
- (void)setXjLoadedTimeRanges:(CGFloat)xjLoadedTimeRanges{
    _xjLoadedTimeRanges = xjLoadedTimeRanges;
    [self.loadProgressView setProgress:_xjLoadedTimeRanges animated:YES];
}

//已播放
- (void)setXjCurrentTime:(CGFloat)xjCurrentTime{
    _xjCurrentTime = xjCurrentTime;
    [self.playSlider setValue:xjCurrentTime animated:YES];
    NSString *time1 = [self xjPlayerTimeStyle:xjCurrentTime];
    NSString *time2 = [self xjPlayerTimeStyle:self.xjTotalTime];
    if (isHour) {
        self.timeLabel.text = [NSString stringWithFormat:@"%@/%@",time1,time2];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:%@/00:%@",time1,time2];
    }
}
//总时长
- (void)setXjTotalTime:(CGFloat)xjTotalTime{
    _xjTotalTime = xjTotalTime;
    NSString *time = [self xjPlayerTimeStyle:_xjTotalTime];
    if (isHour) {
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/%@",time];
    }else{
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/00:%@",time];
    }
    self.playSlider.maximumValue = _xjTotalTime;//设置slider的最大值就是总时长
}

//定义视屏时长样式
- (NSString *)xjPlayerTimeStyle:(CGFloat)time{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:time];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (time/3600>1) {
        isHour = YES;
        [formatter setDateFormat:@"HH:mm:ss"];
    }else{
        [formatter setDateFormat:@"mm:ss"];
    }
    NSString *showTimeStyle = [formatter stringFromDate:date];
    return showTimeStyle;
}

//放大/缩小
- (void)fullOrSmallAction{
    if (self.xjFull) {
        self.xjFull = NO;
    }else{
        self.xjFull = YES;
    }
    if (self.xjFullOrSmallBlock) {
        self.xjFullOrSmallBlock(self.xjFull);
    }
}

//slider拖动时
- (void)playSliderValueChanging:(id)sender{
    isPlay = NO;
    UISlider *slider = (UISlider*)sender;
    if (self.xjSliderValueChangeBlock) {
        self.xjSliderValueChangeBlock(slider.value);
    }
}

//slider完成拖动时
- (void)playSliderValueDidChanged:(id)sender{
    UISlider *slider = (UISlider*)sender;
    if (self.xjSliderValueChangeEndBlock) {
        self.xjSliderValueChangeEndBlock(slider.value);
    }
    [self playOrPauseAction];
}

#pragma mark - **************************** 懒加载 *************************************
- (UIButton *)playOrPauseBtn{
    if (_playOrPauseBtn == nil) {
        _playOrPauseBtn = [[UIButton alloc] init];
        [_playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [_playOrPauseBtn addTarget:self action:@selector(playOrPauseAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playOrPauseBtn;
}

- (UIButton *)nextPlayerBtn{
    if (_nextPlayerBtn == nil) {
        _nextPlayerBtn = [[UIButton alloc] init];
        [_nextPlayerBtn setImage:[UIImage imageNamed:@"button_forward"] forState:UIControlStateNormal];
        [_nextPlayerBtn addTarget:self action:@selector(nextPlayerAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextPlayerBtn;
}

- (UIProgressView *)loadProgressView{
    if (_loadProgressView == nil) {
        _loadProgressView = [[UIProgressView alloc] init];
    }
    return _loadProgressView;
}

- (UISlider *)playSlider{
    if (_playSlider == nil) {
        _playSlider = [[UISlider alloc] init];
        _playSlider.minimumValue = 0.0;
        
        UIGraphicsBeginImageContextWithOptions((CGSize){1,1}, NO, 0.0f);
        UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        [self.playSlider setThumbImage:[UIImage imageNamed:@"icon_progress"] forState:UIControlStateNormal];
        [self.playSlider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
        [self.playSlider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
        
        [_playSlider addTarget:self action:@selector(playSliderValueChanging:) forControlEvents:UIControlEventValueChanged];
        [_playSlider addTarget:self action:@selector(playSliderValueDidChanged:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playSlider;
}

- (UILabel *)timeLabel{
    if (_timeLabel == nil) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:11.0];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.text = @"00:00:00/00:00:00";
    }
    return _timeLabel;
}

- (UIButton *)fullOrSmallBtn{
    if (_fullOrSmallBtn == nil) {
        _fullOrSmallBtn = [[UIButton alloc] init];
        [_fullOrSmallBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
        [_fullOrSmallBtn addTarget:self action:@selector(fullOrSmallAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullOrSmallBtn;
}

- (void)setXjPlayEnd:(BOOL)xjPlayEnd{
    _xjPlayEnd = xjPlayEnd;
    if (_xjPlayEnd) {
        isPlay = NO;
        [self.playOrPauseBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
        [self.playSlider setValue:0.0 animated:YES];
        [self.loadProgressView setProgress:0.0 animated:YES];
        NSString *time = [self xjPlayerTimeStyle:self.xjTotalTime];
        self.timeLabel.text = [NSString stringWithFormat:@"00:00:00/00:%@",time];
    }
}

- (void)setXjPlay:(BOOL)xjPlay{
    
    [self playOrPauseAction];
}

#pragma mark - **************************** 布局 *************************************
- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.playOrPauseBtn.frame = CGRectMake(self.left+5, 8, 36, 23);
    if (self.xjFull) {
        self.nextPlayerBtn.frame = CGRectMake(self.playOrPauseBtn.right, 5, 30, 30);
        [_fullOrSmallBtn setImage:[UIImage imageNamed:@"small"] forState:UIControlStateNormal];
    }else{
        self.nextPlayerBtn.frame = CGRectMake(self.playOrPauseBtn.right+5, 5, 0, 0);
        [_fullOrSmallBtn setImage:[UIImage imageNamed:@"big"] forState:UIControlStateNormal];
    }
    self.fullOrSmallBtn.frame = CGRectMake(self.width-35, 0, 35, self.height);
    self.timeLabel.frame = CGRectMake(self.fullOrSmallBtn.left-108, 10, 108, 20);
    self.loadProgressView.frame = CGRectMake(self.playOrPauseBtn.right+7, 20,self.timeLabel.left-self.playOrPauseBtn.right-self.nextPlayerBtn.width-14, 31);
    self.playSlider.frame = CGRectMake(self.playOrPauseBtn.right+self.nextPlayerBtn.width+5, 5, self.loadProgressView.width+4, 31);
}

@end
