//
//  GXCustomButton.m
//  HelloHaHa
//
//  Created by MrNing on 15/1/8.
//  Copyright (c) 2015年 NingSir. All rights reserved.
//

#import "GXCustomButton.h"

@implementation GXCustomButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
#pragma mark 设置Button内部的image的范围
- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
CGFloat imageW = contentRect.size.width;
    CGFloat imageH = contentRect.size.height * 0.6;
    
    return CGRectMake(0, 4, imageW, imageH);
}

#pragma mark 设置Button内部的title的范围
- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    CGFloat titleY = contentRect.size.height *0.6;
    CGFloat titleW = contentRect.size.width;
    CGFloat titleH = contentRect.size.height - titleY;
    
    return CGRectMake(0, titleY, titleW, titleH);
}

@end
