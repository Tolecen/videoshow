//
//  XJBottomMenu.h
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJBottomMenu : UIView

@property (nonatomic, assign)CGFloat xjTotalTime;
@property (nonatomic, assign)CGFloat xjCurrentTime;
@property (nonatomic, assign)CGFloat xjLoadedTimeRanges;
@property (nonatomic, assign)BOOL xjPlay;//双击时的播放暂停
@property (readwrite)BOOL xjFull;
@property (nonatomic, assign)BOOL xjPlayEnd;
/**
 *  播放/暂停
 */
@property (nonatomic, copy)void (^xjPlayOrPauseBlock)(BOOL flag);
/**
 *  下一个
 */
@property (nonatomic, copy)void (^xjNextPlayerBlock)();
/**
 *  滑动条滑动时
 */
@property (nonatomic, copy)void (^xjSliderValueChangeBlock)(CGFloat value);
/**
 *  滑动条滑动完成
 */
@property (nonatomic, copy)void (^xjSliderValueChangeEndBlock)(CGFloat value);
/**
 *  放大/缩小
 */
@property (nonatomic, copy)void (^xjFullOrSmallBlock)(BOOL flag);

@end
