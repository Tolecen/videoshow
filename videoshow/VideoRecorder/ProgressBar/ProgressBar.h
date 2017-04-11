//
//  ProgressBar.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PROGRESSBAR_H 6
#define MIN_VIDEO_DUR 3
#define MAX_VIDEO_DUR 10

typedef enum {
    ProgressBarProgressStyleNormal,
    ProgressBarProgressStyleDelete,
} ProgressBarProgressStyle;

@interface ProgressBar : UIView
@property (strong, nonatomic) UIView *intervalView;

- (void)setMaxVideoDur:(int)maxDur minDur:(int)minDur;
- (void)setLastProgressToStyle:(ProgressBarProgressStyle)style;
- (void)setLastProgressToWidth:(CGFloat)width;
- (void)deleteLastProgress;
- (void)addProgressView;

- (void)stopShining;
- (void)startShining;

@end
