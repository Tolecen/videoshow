//
//  UIButton+UIButtonImageWithLabel.m
//  Babypai
//
//  Created by ning on 15/4/14.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import "UIButton+UIButtonImageWithLabel.h"

@implementation UIButton (UIButtonImageWithLabel)
- (void)setImage:(UIImage *)image withTitle:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)stateType{
    
    [self.imageView setFrame:CGRectMake(0, 0, 16, 16)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    [self setTitle:title forState:stateType];
    [self setTitleColor:color forState:stateType];
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)];
}

- (void) setImageRight:(UIImage *)image withTitle:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)stateType;
{
    [self.imageView setFrame:CGRectMake(0, 0, 16, 16)];
    [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self setImage:image forState:stateType];
    
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName: self.titleLabel.font}];
    
    [self setTitle:title forState:stateType];
    [self setTitleColor:color forState:stateType];
    
    [self setImageEdgeInsets:UIEdgeInsetsMake(0.0, 0.0, 0.0, -titleSize.width - image.size.width * 2)];
    [self setTitleEdgeInsets:UIEdgeInsetsMake(0.0, - titleSize.width, 0.0, 0.0)];
}

@end
