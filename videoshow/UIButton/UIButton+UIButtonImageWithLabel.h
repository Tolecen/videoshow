//
//  UIButton+UIButtonImageWithLabel.h
//  Babypai
//
//  Created by ning on 15/4/14.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (UIButtonImageWithLabel)
- (void) setImage:(UIImage *)image withTitle:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)stateType;
- (void) setImageRight:(UIImage *)image withTitle:(NSString *)title titleColor:(UIColor *)color forState:(UIControlState)stateType;
@end
