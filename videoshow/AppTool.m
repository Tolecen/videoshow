//
//  AppTool.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AppTool.h"
#import <CoreText/CoreText.h>

@implementation AppTool

//已知宽度和font计算size
+(CGSize)getSizeOfContent:(NSString *)str width:(CGFloat)width font:(CGFloat)font;
{
    NSString * string = [self nullString:str];
    CGSize size =CGSizeMake(width,CGFLOAT_MAX);
    UIFont *tfont = [UIFont systemFontOfSize:font];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize;
//    if(IOS7OrPlus){
    actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
//    }
//    else if (IOS7Below){
//        actualsize = [str sizeWithFont:tfont constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
//    }
    //强制转化为整型(比初值偏小)，因为float型size转到view上会有一定的偏移，导致view setBounds时候 错位
    CGSize contentSize =CGSizeMake((NSInteger)actualsize.width, (NSInteger)actualsize.height + 1);
    return contentSize;
}


//已知高度和font计算size
+(CGSize)getSizeOfContent:(NSString *)str height:(CGFloat)height font:(CGFloat)font;
{
    NSString * string = [self nullString:str];
    CGSize size =CGSizeMake(CGFLOAT_MAX,height);
    UIFont *tfont = [UIFont systemFontOfSize:font];
    
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:tfont,NSFontAttributeName,nil];
    CGSize  actualsize;
    actualsize =[string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin  attributes:tdic context:nil].size;
    
    //强制转化为整型(比初值偏小)，因为float型size转到view上会有一定的偏移，导致view setBounds时候 错位
    CGSize contentSize =CGSizeMake((NSInteger)actualsize.width + 1, (NSInteger)actualsize.height);
    return contentSize;
}


//已知颜色创建纯色image
+ (UIImage *) createImageFromColor:(UIColor *)color withRect:(CGRect)rect;
{
    if (color == nil) {
        color = [UIColor clearColor];
    }
    if (rect.size.height == 0 || rect.size.width == 0) {
        rect = CGRectMake(0, 0, 1, 1);
    }
    
    UIGraphicsBeginImageContext(rect.size);
    UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}


+ (NSString *) toStrByUIColor:(UIColor *)color;
{
    CGFloat r, g, b, a;
    
    [color getRed:&r green:&g blue:&b alpha:&a];
    
    int rgb = (int) (r * 255.0f)<<16 | (int) (g * 255.0f)<<8 | (int) (b * 255.0f)<<0;
    
    return [NSString stringWithFormat:@"%06x", rgb];
}



//string是否为空
+ (NSString *) nullString:(NSString *)string
{
    if(string.length >0){
        return string;
    }
    return @"--";
}

@end
