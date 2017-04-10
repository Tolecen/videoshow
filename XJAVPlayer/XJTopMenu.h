//
//  XJTopMenu.h
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XJTopMenu : UIView

#pragma mark - **************************** 外部接口 *************************************
/**
 *  标题
 */
@property (nonatomic, strong) NSString *xjAvTitle;
/**
 *  隐藏返回按钮
 *  默认为NO;
 */
@property (readwrite)BOOL xjHidenBackBtn;
/**
 *  返回按钮操作
 */
@property (nonatomic , copy) void(^xjTopGoBack)();

@end
