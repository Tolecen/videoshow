//
//  XJGestureButton.m
//  XJAVPlayer
//
//  Created by xj_love on 16/9/6.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XJGestureButton.h"
#import <MediaPlayer/MediaPlayer.h>

typedef NS_ENUM(NSUInteger, Direction) {
    DirectionLeftOrRight,
    DirectionUpOrDown,
    DirectionNone
};

#define WS(weakSelf) __unsafe_unretained __typeof(&*self)weakSelf = self;

@interface XJGestureButton (){
    BOOL isHiden;
}

//上下左右手势操作
@property (nonatomic, assign) Direction direction;
@property (nonatomic, assign) CGPoint startPoint;//手势触摸起始位置
@property (nonatomic, assign) CGFloat startVB;//记录当前音量/亮度
@property (nonatomic, strong) MPVolumeView *volumeView;//控制音量的view
@property (nonatomic, strong) UISlider *volumeViewSlider;//控制音量
@property (nonatomic, assign) CGFloat startVideoRate;//开始进度
@property (nonatomic, assign) CGFloat currentRate;//当期视频播放的进度

@end

@implementation XJGestureButton

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addGestureAction];
        isHiden = YES;
    }
    return self;
}

- (void)addGestureAction{
    UITapGestureRecognizer *xjTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureAction:)];
    xjTapGesture.numberOfTapsRequired = 1;
    xjTapGesture.delegate = self;
    [self addGestureRecognizer:xjTapGesture];
    
    UITapGestureRecognizer *xjTwoTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTapGestureAction:)];
    xjTwoTapGesture.numberOfTapsRequired = 2;
    xjTwoTapGesture.delegate = self;
    [self addGestureRecognizer:xjTwoTapGesture];
    
    [xjTapGesture requireGestureRecognizerToFail:xjTwoTapGesture];//没有检测到双击才进行单击事件
}

- (void)userTapGestureAction:(UITapGestureRecognizer*)tap{
    if (tap.numberOfTapsRequired == 1) {
        if (isHiden) {
            isHiden = NO;
        }else{
            isHiden = YES;
        }
    }
    if (self.userTapGestureBlock) {
        self.userTapGestureBlock(tap.numberOfTapsRequired,isHiden);
    }
}

//触摸开始
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    //获取触摸开始的坐标
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    
    WS(weakSelf);
    //记录首次触摸坐标
    weakSelf.startPoint = point;
    //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是音量，右边是亮度
    if (weakSelf.startPoint.x <= weakSelf.frame.size.width / 2.0) {
        //音/量
        weakSelf.startVB = weakSelf.volumeViewSlider.value;
    } else {
        //亮度
        weakSelf.startVB = [UIScreen mainScreen].brightness;
    }
    //方向置为无
    weakSelf.direction = DirectionNone;
    
    if (self.touchesBeganWithPointBlock) {
        self.startVideoRate = self.touchesBeganWithPointBlock();
    }
}

//触摸结束
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    
    WS(weakSelf);
    if (weakSelf.direction == DirectionLeftOrRight) {
        if (self.touchesEndWithPointBlock) {
            self.touchesEndWithPointBlock(self.currentRate);
        }
    }
}

//移动
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint panPoint = [touch locationInView:self];
    
    //得出手指在Button上移动的距离
    CGPoint point = CGPointMake(panPoint.x - self.startPoint.x, panPoint.y - self.startPoint.y);
    
    WS(weakSelf);
    //分析出用户滑动的方向
    if (weakSelf.direction == DirectionNone) {
        if (point.x >= 30 || point.x <= -30) {
            //进度
            weakSelf.direction = DirectionLeftOrRight;
        } else if (point.y >= 30 || point.y <= -30) {
            //音量和亮度
            weakSelf.direction = DirectionUpOrDown;
        }
    }
    
    if (weakSelf.direction == DirectionNone) {
        return;
    } else if (weakSelf.direction == DirectionUpOrDown) {
        //音量和亮度
        if (weakSelf.startPoint.x <= weakSelf.frame.size.width / 2.0) {
            //音量
            if (point.y < 0) {
                //增大音量
                [weakSelf.volumeViewSlider setValue:weakSelf.startVB + (-point.y / 30.0 / 10) animated:YES];
                if (weakSelf.startVB + (-point.y / 30 / 10) - weakSelf.volumeViewSlider.value >= 0.1) {
                    [weakSelf.volumeViewSlider setValue:0.1 animated:NO];
                    [weakSelf.volumeViewSlider setValue:weakSelf.startVB + (-point.y / 30.0 / 10) animated:YES];
                }
                
            } else {
                //减少音量
                [weakSelf.volumeViewSlider setValue:weakSelf.startVB - (point.y / 30.0 / 10) animated:YES];
            }
            
        } else{
            //调节亮度
            if (point.y < 0) {
                //增加亮度
                [[UIScreen mainScreen] setBrightness:weakSelf.startVB + (-point.y / 30.0 / 10)];
            } else {
                //减少亮度
                [[UIScreen mainScreen] setBrightness:weakSelf.startVB - (point.y / 30.0 / 10)];
            }
        }
    } else if (weakSelf.direction == DirectionLeftOrRight) {
        
        //进度
        CGFloat rate = weakSelf.startVideoRate + (point.x / 30.0 / 20.0);
        if (rate > 1) {
            rate = 1;
        } else if (rate < 0) {
            rate = 0;
        }
        weakSelf.currentRate = rate;
    }
}

- (MPVolumeView *)volumeView {
    if (_volumeView == nil) {
        _volumeView  = [[MPVolumeView alloc] init];
        [_volumeView sizeToFit];
        for (UIView *view in [_volumeView subviews]){
            if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
                self.volumeViewSlider = (UISlider*)view;
                break;
            }
        }
    }
    return _volumeView;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    self.volumeView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.width * 9.0 / 16.0);
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    for (UIView *subView in self.subviews) {
        if ([touch.view isDescendantOfView:subView]) {
            return NO;
        }
    }
    return YES;
}

@end
