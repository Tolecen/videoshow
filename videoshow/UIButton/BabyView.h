//
//  BabyView.h
//  Babypai
//
//  Created by ning on 15/4/12.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BabyView : UIView


+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration;

+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat;

+ (void)shakeView:(UIView *)view duration:(CGFloat)fDuration;

@end
