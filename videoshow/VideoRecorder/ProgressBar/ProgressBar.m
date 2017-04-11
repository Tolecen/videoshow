//
//  ProgressBar.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "ProgressBar.h"
#import "MacroDefinition.h"

#define TIMER_INTERVAL 1.0f

@interface ProgressBar ()

@property (strong, nonatomic) NSMutableArray *progressViewArray;

@property (strong, nonatomic) UIView *barView;
@property (strong, nonatomic) UIImageView *progressIndicator;

@property (strong, nonatomic) NSTimer *shiningTimer;

@end

@implementation ProgressBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    self.autoresizingMask = UIViewAutoresizingNone;
    self.backgroundColor = [UIColor blackColor];
    self.progressViewArray = [[NSMutableArray alloc] init];
    
    //barView
    self.barView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, PROGRESSBAR_H)];
    _barView.backgroundColor = [UIColor blackColor];
    [self addSubview:_barView];
    
    //最短分割线
    
    CGFloat left = (MIN_VIDEO_DUR * 1.0 / MAX_VIDEO_DUR) * SCREEN_WIDTH;
    
    self.intervalView = [[UIView alloc] initWithFrame:CGRectMake(left, 0, 1.5, PROGRESSBAR_H)];
    _intervalView.backgroundColor = UIColorFromRGB(BABYCOLOR_camera_progress_three);
    [_barView addSubview:_intervalView];
    
    //indicator
    self.progressIndicator = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 4, PROGRESSBAR_H)];
    _progressIndicator.backgroundColor = UIColorFromRGB(BABYCOLOR_camera_progress_split);
    _progressIndicator.center = CGPointMake(0, PROGRESSBAR_H / 2);
    [self addSubview:_progressIndicator];
}

- (void)setMaxVideoDur:(int)maxDur minDur:(int)minDur
{
    CGFloat left = (minDur / maxDur) * SCREEN_WIDTH;
    CGRect frame = CGRectMake(left, 0, 1.5, PROGRESSBAR_H);
    self.intervalView.frame = frame;
}

- (UIView *)getProgressView
{
    UIView *progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, PROGRESSBAR_H)];
    progressView.backgroundColor = UIColorFromRGB(BABYCOLOR_background_gray);
    progressView.autoresizesSubviews = YES;
    
    return progressView;
}

- (void)refreshIndicatorPosition
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        _progressIndicator.center = CGPointMake(0, PROGRESSBAR_H / 2);
        return;
    }
    
    _progressIndicator.center = CGPointMake(MIN(lastProgressView.frame.origin.x + lastProgressView.frame.size.width, self.frame.size.width - _progressIndicator.frame.size.width / 2 + 2), PROGRESSBAR_H / 2);
}

- (void)onTimer:(NSTimer *)timer
{
    [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
        _progressIndicator.alpha = 0;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:TIMER_INTERVAL / 2 animations:^{
            _progressIndicator.alpha = 1;
        }];
    }];
}

#pragma mark - method
- (void)startShining
{
    self.shiningTimer = [NSTimer scheduledTimerWithTimeInterval:TIMER_INTERVAL target:self selector:@selector(onTimer:) userInfo:nil repeats:YES];
}

- (void)stopShining
{
    [_shiningTimer invalidate];
    self.shiningTimer = nil;
    _progressIndicator.alpha = 1;
}

- (void)addProgressView
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    CGFloat newProgressX = 0.0f;
    
    if (lastProgressView) {
        CGRect frame = lastProgressView.frame;
        frame.size.width -= 1;
        lastProgressView.frame = frame;
        
        newProgressX = frame.origin.x + frame.size.width + 1;
    }
    
    UIView *newProgressView = [self getProgressView];
    
    CGRect frame = newProgressView.frame;
    frame.origin.x = newProgressX;
    newProgressView.frame = frame;
    
    [_barView addSubview:newProgressView];
    
    [_progressViewArray addObject:newProgressView];
}

- (void)setLastProgressToWidth:(CGFloat)width
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    CGRect frame = lastProgressView.frame;
    frame.size.width = width;
    lastProgressView.frame = frame;
    
    [self refreshIndicatorPosition];
}

- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    switch (style) {
        case ProgressBarProgressStyleDelete:
        {
            lastProgressView.backgroundColor = UIColorFromRGB(BABYCOLOR_base_color);
            _progressIndicator.hidden = YES;
        }
            break;
        case ProgressBarProgressStyleNormal:
        {
            lastProgressView.backgroundColor = UIColorFromRGB(BABYCOLOR_background_gray);
            _progressIndicator.hidden = NO;
        }
            break;
        default:
            break;
    }
}

- (void)deleteLastProgress
{
    UIView *lastProgressView = [_progressViewArray lastObject];
    if (!lastProgressView) {
        return;
    }
    
    [lastProgressView removeFromSuperview];
    [_progressViewArray removeLastObject];
    
    _progressIndicator.hidden = NO;
    
    [self refreshIndicatorPosition];
}

@end
