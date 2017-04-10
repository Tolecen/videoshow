//
//  XJGestureButton.h
//  XJAVPlayer
//
//  Created by xj_love on 16/9/6.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJGestureButton : UIButton<UIGestureRecognizerDelegate>
/**
 *  单击时/双击时,判断tap的numberOfTapsRequired
 */
@property (nonatomic, copy)void (^userTapGestureBlock)(NSUInteger number,BOOL flag);
/**
 * 开始触摸
 */
@property (nonatomic, copy)CGFloat (^touchesBeganWithPointBlock)();
/**
 * 结束触摸
 */
@property (nonatomic, copy)void (^touchesEndWithPointBlock)(CGFloat rate);

@end
