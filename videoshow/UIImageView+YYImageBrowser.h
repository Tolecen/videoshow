//
//  UIImageView+YYImageBrowser.h
//  PogoShow
//
//  Created by yan ruichen on 14-8-18.
//  Copyright (c) 2014年 mRocker. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ImageViewBlock)(UIImageView* imageView);


@interface UIImageView (YYImageBrowser)
/**
 *  开启图片浏览的方法
 */
@property(nonatomic)BOOL browseEnabled;
/**
 *  放大后的背景颜色，可以改为自定义颜色，默认为黑色
 */
@property(readwrite, nonatomic)UIColor *browserBackgroundColor;//default is black;
/**
 *  默认为keyWindow 如果设置为nil，则自动换位keyWindow
 */
@property(readwrite, nonatomic)UIView* addToView;//default is keyWindow, if set nil, it will turn to default
/**
 *  可选参数，如果不为nil，将会在放大后开始加载相应的图片（使用AFNetWorking框架）
 */
@property(strong, nonatomic)NSURL* realImageURL;
/**
 *  放大前长按图片的回调block
 */
-(void)setImageLongPressHandler:(ImageViewBlock)longPressBlock;
/**
 *  放大后长按图片的回调block
 */
-(void)setBrowserLongPressHandler:(ImageViewBlock)longPressBlock;
/**
 *  展示图片（目前全部带有动画）
 */
-(void)showAnimated:(BOOL)animated;
/**
 *  收回图片（目前全部带有动画）
 */
-(void)hideAnimated:(BOOL)animated;

@end

















