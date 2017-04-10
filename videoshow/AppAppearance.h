//
//  AppAppearance.h
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>

//存储app外观颜色 
@interface AppAppearance : NSObject

+(instancetype)sharedAppearance;
/**
 *  主色调，主要用于导航栏背景
 */
@property(readonly, nonatomic) UIColor *mainColor;

/**
 *  弹出视图的背景遮罩颜色
 */
@property (readonly, nonatomic) UIColor *alertBackgroundColor;


//轮播图默认底图
@property (nonatomic, strong) UIImage *defaultImage;

@end
