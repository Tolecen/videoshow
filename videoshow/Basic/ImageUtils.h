//
//  ImageUtils.h
//  Babypai
//
//  Created by ning on 16/4/22.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroDefinition.h"

@interface ImageUtils : NSObject

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageFromTextOriginWith:(NSString *) text withFont: (CGFloat)fontSize;
+ (UIImage *)imageFromText:(NSArray *) arrContent withFont: (CGFloat)fontSize;
+ (UIImage *)getVideoPreViewImage:(NSString *)videoPath withTime:(float)time;
+ (UIImage *)handleImage:(UIImage *)originalImage withSize:(CGSize)size;


@end
