//
//  AdView.m
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AdView.h"
#import "UserModel.h"

@interface AdView ()

@property (nonatomic, strong) UIButton *tempBtn;
@property (nonatomic, strong) UIImageView * advertisingView;
@property (nonatomic, strong) UIButton * advertisingJumpButton;
@property (nonatomic, strong) UIButton * timeLabel;
@property (nonatomic, strong) UIButton *leaveBtn;
@property (nonatomic, assign) int secondsCountDown;
@property (nonatomic, strong) NSTimer * countDownTimer;
/** 定时器(这里不用带*，因为dispatch_source_t就是个类，内部已经包含了*) */
@property (nonatomic, strong) dispatch_source_t timer;

@end

@implementation AdView

- (instancetype) initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        [self addSubview:self.advertisingView];
        [self addSubview:self.advertisingJumpButton];
        [self addSubview:self.timeLabel];
        [self addSubview:self.tempBtn];
    }
    return self;
}

- (void) startplayAdvertisingView:(void (^)(AdView *))advertisingview
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:self];
    // 这里的block advertisingview ;
    // advertisingview(); 你要调用就要传参数过去，调用的具体代码在 APPdelegate 里面调用的时候添加这个 block具体的代码、、、
    __block int count = 5;//设置时间5s
    // 获得队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建一个定时器(dispatch_source_t本质还是个OC对象)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 设置定时器的各种属性（几时开始任务，每隔多长时间执行一次）
    // GCD的时间参数，一般是纳秒（1秒 == 10的9次方纳秒）
    // 何时开始执行第一个任务
    // dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC) 比当前时间晚3秒
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC));
    uint64_t interval = (uint64_t)(1.0 * NSEC_PER_SEC);
    dispatch_source_set_timer(self.timer, start, interval, 0);
    // 设置回调
    dispatch_source_set_event_handler(self.timer, ^{
        /**
         *  回主线程更新UI
         */
        count--;
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if (count == 0) {
                
                [self leaveSelfAction:advertisingview];
                
            }else if (count < 3) {//小于3s显示跳过
                
                _timeLabel.hidden = YES;
                [self addSubview:self.leaveBtn];
            }else{
                [_timeLabel setTitle:[NSString  stringWithFormat:@"%d",count] forState:UIControlStateNormal];
            }
        });
    });
    // 启动定时器
    dispatch_resume(self.timer);
}

- (void) leaveSelfAction:(void (^)(AdView *))advertisingview
{
    // 取消定时器
    if (self.timer != nil) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    [UIView animateWithDuration:0.68 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    /**
     *  广告显示完，就调用 block 
     */
    advertisingview(self);
}

//点击跳过action
- (void) leaveSelfAction
{
    // 取消定时器
    if (self.timer != nil) {
        dispatch_cancel(self.timer);
        self.timer = nil;
    }
    [UIView animateWithDuration:0.68 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    self.leavBlock();
}

- (UIButton *) tempBtn
{
    if (!_tempBtn) {
        _tempBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _tempBtn.frame = CGRectMake(0, 0, 50, 25);
        [_tempBtn setBackgroundColor:UIColorFromRGB(0x929292)];
        [_tempBtn setTitle:@"广告" forState:UIControlStateNormal];
        _tempBtn.titleLabel.font = [UIFont systemFontOfSize:9];
        [_tempBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _tempBtn;
}

- (UIImageView * ) advertisingView
{
    if (_advertisingView == nil) {
        _advertisingView =[[UIImageView  alloc]initWithFrame:self.bounds];
        
        NSDictionary *dict = [AppDataManager defaultManager].adDic;
        _advertisingView.image = [UIImage imageWithData:dict[@"imageData"]];
    }
    return _advertisingView;
}

- (UIButton * ) timeLabel
{
    if (_timeLabel == nil) {
        
        _timeLabel = [UIButton buttonWithType:UIButtonTypeCustom];
        _timeLabel.frame = CGRectMake(self.bounds.size.width - self.leaveBtn.width-20, 20, self.leaveBtn.width, self.leaveBtn.height);
        _timeLabel.backgroundColor = UIColorFromRGB(0x929292);
//        _timeLabel.alpha = 0.5;
        _timeLabel.layer.masksToBounds = YES;
        _timeLabel.layer.cornerRadius = 20;
        _timeLabel.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_timeLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_timeLabel addTarget:self action:@selector(leaveSelfAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _timeLabel;
}

- (UIButton *) leaveBtn
{
    if (_leaveBtn == nil) {
        _leaveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _leaveBtn.frame = CGRectMake(self.bounds.size.width - 20-40, 20, 40, 40);
        _leaveBtn.layer.cornerRadius = 20;
        [_leaveBtn addTarget:self action:@selector(leaveSelfAction) forControlEvents:UIControlEventTouchUpInside];
        [_leaveBtn setBackgroundColor:UIColorFromRGB(0x929292)];
        [_leaveBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_leaveBtn setTitle:@"跳过" forState:UIControlStateNormal];
        _leaveBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    }
    return _leaveBtn;
}

- (UIButton * )advertisingJumpButton
{
    if (_advertisingJumpButton == nil) {
        _advertisingJumpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _advertisingJumpButton.frame =  CGRectMake(MainScreenSize.width - 60, self.bounds.size.height - 100, 60, 40);
        [_advertisingJumpButton setTitle:@"查看详情" forState:UIControlStateNormal];
        [_advertisingJumpButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_advertisingJumpButton addTarget:self action:@selector(buttonclick) forControlEvents:UIControlEventTouchUpInside];
        _advertisingJumpButton.titleLabel.font = [UIFont systemFontOfSize:13];
        _advertisingJumpButton.backgroundColor = UIColorFromRGB(0x929292);
//        _advertisingJumpButton.alpha = 0.5;
        _advertisingJumpButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _advertisingJumpButton;
}


- (void) buttonclick
{
    WeakTypeof(weakSelf)
    if (![weakSelf.detailBlock isEqual:[NSNull null]]) {
        __strong typeof(self) strongSelf = self;
        weakSelf.detailBlock(strongSelf);
    }
}



@end
