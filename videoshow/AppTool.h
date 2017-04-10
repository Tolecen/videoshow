//
//  AppTool.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppTool : NSObject

//已知宽度和font计算size
+(CGSize)getSizeOfContent:(NSString *)str width:(CGFloat)width font:(CGFloat)font;


//已知高度和font计算size
+(CGSize)getSizeOfContent:(NSString *)str height:(CGFloat)height font:(CGFloat)font;


//已知颜色创建纯色image
+ (UIImage *) createImageFromColor:(UIColor *)color withRect:(CGRect)rect;


//已知UIColor转换成16进制
+ (NSString *) toStrByUIColor:(UIColor *)color;



@end
