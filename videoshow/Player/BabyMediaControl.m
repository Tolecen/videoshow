//
//  BabyMediaControl.m
//  Babypai
//
//  Created by ning on 16/5/9.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyMediaControl.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "SVIndefiniteAnimatedView.h"
#import "MacroDefinition.h"

#define textW 40
#define textH 20
#define sliderBottom 6

@interface BabyMediaControl ()

@property(nonatomic,strong) UIView *miniOverlayPanel;
@property(nonatomic,strong) UIProgressView *mediaProgress;

@property(nonatomic,strong) UIView *overlayPanel;
@property(nonatomic,strong) UIButton *playButton;

@property(nonatomic,strong) UILabel *videoTime;

@property(nonatomic,strong) UIImageView *bottomImage;

@property(nonatomic,strong) UILabel *currentTimeLabel;
@property(nonatomic,strong) UILabel *totalDurationLabel;
@property(nonatomic,strong) UISlider *mediaProgressSlider;

@end

@implementation BabyMediaControl
{
    BOOL _isMediaSliderBeingDragged;
    SVIndefiniteAnimatedView *_loadingView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    // 设置view
    
    self.miniOverlayPanel = [[UIView alloc]initWithFrame:CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 2)];
    self.miniOverlayPanel.backgroundColor = [UIColor purpleColor];
    [self addSubview:self.miniOverlayPanel];
    
    self.mediaProgress = [[UIProgressView alloc]init];
    self.mediaProgress.frame = CGRectMake(0, 0, self.miniOverlayPanel.bounds.size.width, 2);
    self.mediaProgress.progressTintColor = UIColorFromRGB(BABYCOLOR_base_color);
    self.mediaProgress.trackTintColor = [UIColor whiteColor];
    [self.miniOverlayPanel addSubview:self.mediaProgress];
    

    self.overlayPanel = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
    self.overlayPanel.hidden = YES;
    [self addSubview:self.overlayPanel];
    self.overlayPanel.clipsToBounds = YES;
    self.playButton = [[UIButton alloc]initWithFrame:CGRectMake((self.bounds.size.width - 80) / 2 ,  (self.bounds.size.height - 80) / 2, 80, 80)];
    [self.playButton setImage:ImageNamed(@"baby_rcd_btn_play") forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(pressPlayBtn) forControlEvents:UIControlEventTouchUpInside];
    self.playButton.hidden = YES;
    [self.overlayPanel addSubview:self.playButton];
    
    self.videoTime = [[UILabel alloc]initWithFrame:CGRectMake((self.bounds.size.width - textW - 10), 10, textW, textH)];
    self.videoTime.textColor = [UIColor whiteColor];
    self.videoTime.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
    self.videoTime.textAlignment = NSTextAlignmentCenter;
    self.videoTime.layer.borderColor = [UIColor whiteColor].CGColor;
    self.videoTime.layer.borderWidth = 1;
    self.videoTime.backgroundColor = UIColorFromRGBA(BABYCOLOR_comment_text, 0.3);
    self.videoTime.layer.cornerRadius = 6;
    self.videoTime.clipsToBounds = YES;
    self.videoTime.hidden = YES;
    [self.overlayPanel addSubview:self.videoTime];
    
    self.bottomImage = [[UIImageView alloc]initWithImage:ImageNamed(@"shadow_asset")];
    self.bottomImage.frame = CGRectMake(0, self.bounds.size.height - 65, self.bounds.size.width, 65);
    self.layer.zPosition = 0;
    [self.overlayPanel addSubview:self.bottomImage];
    
    
    self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, (self.bounds.size.height), textW, textH)];
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.font = kFontSizeSmall;
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    [self.overlayPanel insertSubview:self.currentTimeLabel aboveSubview:self.bottomImage];
    
    self.totalDurationLabel = [[UILabel alloc]initWithFrame:CGRectMake((self.bounds.size.width - 10 - textW), (self.bounds.size.height), textW, textH)];
    self.totalDurationLabel.textColor = [UIColor whiteColor];
    self.totalDurationLabel.font = kFontSizeSmall;
    self.totalDurationLabel.textAlignment = NSTextAlignmentCenter;
    [self.overlayPanel insertSubview:self.totalDurationLabel aboveSubview:self.bottomImage];
    
    self.mediaProgressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20 + textW, self.frame.size.height-textH, (self.bounds.size.width - 2 * (textW + 20)), textH)];
    self.mediaProgressSlider.backgroundColor = [UIColor clearColor];
    self.mediaProgressSlider.value = 1.0;
    self.mediaProgressSlider.minimumValue = 0.5;
    self.mediaProgressSlider.maximumValue = 1.0;
    [self.mediaProgressSlider setMinimumTrackTintColor:UIColorFromRGB(BABYCOLOR_base_color)];
    [self.mediaProgressSlider setMaximumTrackTintColor:[UIColor whiteColor]];
    [self.mediaProgressSlider setThumbImage:ImageNamed(@"tabbar_badge") forState:UIControlStateNormal];
    [self.overlayPanel insertSubview:self.mediaProgressSlider aboveSubview:self.bottomImage];
    
    _loadingView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectMake((self.bounds.size.width - 40) / 2 ,  (self.bounds.size.height - 40) / 2, 40, 40)];
    _loadingView.strokeColor = [UIColor whiteColor];
    _loadingView.strokeThickness = 2;
    _loadingView.radius = 18;
    [self addSubview:_loadingView];
    
    if([_loadingView respondsToSelector:@selector(startAnimating)]) {
        [(id)_loadingView startAnimating];
    }
    
    //滑动过程中不断触发事件
    [self.mediaProgressSlider addTarget:self action:@selector(continueDragMediaSlider) forControlEvents:UIControlEventValueChanged];
    
    [self.mediaProgressSlider addTarget:self action:@selector(beginDragMediaSlider) forControlEvents:UIControlEventTouchDown];
    
    [self.mediaProgressSlider addTarget:self action:@selector(didSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mediaProgressSlider addTarget:self action:@selector(endDragMediaSlider) forControlEvents:UIControlEventTouchUpOutside];
    
    [self.mediaProgressSlider addTarget:self action:@selector(endDragMediaSlider) forControlEvents:UIControlEventTouchCancel];
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playMeida)];
    
    [self addGestureRecognizer:tap];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.overlayPanel.hidden = NO;
    });
    
    
    [self refreshMediaControl];
}

- (void)didSliderTouchUpInside
{
    self.delegatePlayer.currentPlaybackTime = self.mediaProgressSlider.value;
    [self endDragMediaSlider];
}

- (void)playMeida
{
    [self showAndFade];
    if ([self.delegatePlayer isPlaying]) {
        [self.delegatePlayer pause];
        [self showNoFade];
    } else {
        [self.delegatePlayer play];
        [self showAndFade];
    }
    
    [self refreshMediaControl];
}

- (void)showNoFade
{
    self.miniOverlayPanel.hidden = YES;
    [self sliderHide:NO];
    [self cancelDelayedHide];
    [self refreshMediaControl];
}

- (void)showAndFade
{
    [self showNoFade];
    [self performSelector:@selector(hide) withObject:nil afterDelay:3];
}

- (void)hide
{
    self.miniOverlayPanel.hidden = NO;
    [self sliderHide:YES];
    [self cancelDelayedHide];
}

- (void)showLoading:(BOOL)isLoading
{
    if (isLoading) {
        _loadingView.hidden = NO;
    } else {
        _loadingView.hidden = YES;
    }
}

- (void)hideAndRefresh
{
    self.miniOverlayPanel.hidden = NO;
    [self sliderHide:YES];
    [self refreshMediaControl];
}

- (void)sliderHide:(BOOL)hidden
{
    CGRect mediaProgressSliderFrame = self.mediaProgressSlider.frame;
    CGRect currentTimeLabelFrame = self.currentTimeLabel.frame;
    CGRect totalDurationLabelFrame = self.totalDurationLabel.frame;
    
    CGFloat bottomImageAlpha = self.bottomImage.alpha;
    
    if (hidden) {
        mediaProgressSliderFrame.origin.y = self.bounds.size.height;
        currentTimeLabelFrame.origin.y = self.bounds.size.height;
        totalDurationLabelFrame.origin.y = self.bounds.size.height;
        
        bottomImageAlpha = 0.0f;
        
    } else {
        mediaProgressSliderFrame.origin.y = self.bounds.size.height - textH - sliderBottom;
        currentTimeLabelFrame.origin.y = self.bounds.size.height - textH - sliderBottom;
        totalDurationLabelFrame.origin.y = self.bounds.size.height - textH - sliderBottom;
        
        bottomImageAlpha = 1.0f;
    }
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    // set views with new info
    self.mediaProgressSlider.frame = mediaProgressSliderFrame;
    self.currentTimeLabel.frame = currentTimeLabelFrame;
    self.totalDurationLabel.frame = totalDurationLabelFrame;
    self.bottomImage.alpha = bottomImageAlpha;
    
    // commit animations
    [UIView commitAnimations];
}

- (void)cancelDelayedHide
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hide) object:nil];
}

- (void)pressPlayBtn
{
    if (![self.delegatePlayer isPlaying]) {
        [self.delegatePlayer play];
    }
    [self showAndFade];
}

- (void)beginDragMediaSlider
{
    _isMediaSliderBeingDragged = YES;
}

- (void)endDragMediaSlider
{
    _isMediaSliderBeingDragged = NO;
}

- (void)continueDragMediaSlider
{
    [self refreshMediaControl];
}

- (void)refreshMediaControl
{
    // duration
    NSTimeInterval duration = self.delegatePlayer.duration;
    NSInteger intDuration = duration + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.maximumValue = duration;

        self.totalDurationLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intDuration / 60), (int)(intDuration % 60)];
        NSString *time = [NSString stringWithFormat:@"%d秒", (int)duration];
        self.videoTime.text = time;
        
        CGSize timeSize = [time sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:12]}];
        CGFloat x = MAX(timeSize.width + 10, textW);
        self.videoTime.frame = CGRectMake((self.bounds.size.width - x - 10), 10, x, textH);
        
    } else {
        self.videoTime.hidden = YES;
        self.totalDurationLabel.text = @"--:--";
        self.mediaProgressSlider.maximumValue = 1.0f;
    }
    
    
    // position
    NSTimeInterval position;
    if (_isMediaSliderBeingDragged) {
        position = self.mediaProgressSlider.value;
    } else {
        position = self.delegatePlayer.currentPlaybackTime;
    }
    NSInteger intPosition = position + 0.5;
    if (intDuration > 0) {
        self.mediaProgressSlider.value = position;
        self.mediaProgress.progress = position * 1.0 / duration;
    } else {
        self.mediaProgressSlider.value = 0.0f;
        self.mediaProgress.progress = 0.0f;
    }
    self.currentTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d", (int)(intPosition / 60), (int)(intPosition % 60)];
    
    
    // status
    BOOL isPlaying = [self.delegatePlayer isPlaying];
    self.playButton.hidden = isPlaying;
    self.videoTime.hidden = isPlaying;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}

@end
