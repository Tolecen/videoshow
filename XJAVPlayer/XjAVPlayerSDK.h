//
//  XjAVPlayerSDK.h
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol XjAVPlayerSDKDelegate <NSObject>

@optional
- (void)xjGoBack;//返回按钮
- (void)xjNextPlayer;//下一个
@end

@interface XjAVPlayerSDK : UIView

#pragma mark - **************************** 外部接口 *************************************
/**
 *  代理
 */
@property (nonatomic, strong)id<XjAVPlayerSDKDelegate> XjAVPlayerSDKDelegate;
/**
 *  视屏播放链接
 */
@property (nonatomic, strong)NSString *xjPlayerUrl;
/**
 *  视屏标题
 */
@property (nonatomic, strong)NSString *xjPlayerTitle;
/**
 *  定位上次播放时间
 */
@property (nonatomic, assign)int xjLastTime;
/**
 *  是否开启自动横屏
 *  默认NO
 */
@property (readwrite)BOOL xjAutoOrient;
/**
 *  关闭播放器
 */
- (void)xjStopPlayer;
/**
 *  获取当前播放时间
 *
 *  @return
 */
- (CGFloat)xjCurrentTime;
/**
 *  获取视屏总长
 *
 *  @return
 */
- (CGFloat)xjTotalTime;

@end
