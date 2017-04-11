//
//  BabyView.m
//  Babypai
//
//  Created by ning on 15/4/12.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import "BabyView.h"
#import <QuartzCore/QuartzCore.h>

@implementation BabyView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


// 心跳动画
+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration
{
    [self heartbeatView:view duration:fDuration maxSize:1.4f durationPerBeat:0.5f];
}
+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat
{
    if (view && (fDurationPerBeat > 0.1f))
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.05],
                               [NSNumber numberWithFloat:0.2],
        [NSNumber numberWithFloat:0.6],
        [NSNumber numberWithFloat:1.0],
        nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.duration = fDurationPerBeat;
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [view.layer addAnimation:animation forKey:@"heartbeatView"];
        }else{}
    
}





// 视图抖动动画
+ (void)shakeView:(UIView *)view duration:(CGFloat)fDuration
{
    if (view && (fDuration >= 0.1f))
    {
        CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //设置抖动幅度
        shake.fromValue = [NSNumber numberWithFloat:-0.3];
        shake.toValue = [NSNumber numberWithFloat:+0.3];
        shake.duration = 0.1f;
        shake.repeatCount = fDuration/4/0.1f;
        shake.autoreverses = YES;
        [view.layer addAnimation:shake forKey:@"shakeView"];
    }else{}
    
}


@end
