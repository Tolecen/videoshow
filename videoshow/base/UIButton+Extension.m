//
//  UIButton+Extension.m
//  Babypai
//
//  Created by ning on 16/4/22.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "UIButton+Extension.h"
#import "ImageUtils.h"
#import <objc/runtime.h>

@implementation UIButton (Extension)

static char kActivityIndicatorKey;
@dynamic activityIndicator;
static char kWokingKey;
@dynamic working;

- (void)setActivityIndicator:(UIActivityIndicatorView *)activityIndicator
{
    objc_setAssociatedObject(self, &kActivityIndicatorKey,
                             activityIndicator,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIActivityIndicatorView *)activityIndicator
{
    return objc_getAssociatedObject(self, &kActivityIndicatorKey);
}

- (void)setWorking:(BOOL)working
{
    objc_setAssociatedObject(self, &kWokingKey,
                             [NSNumber numberWithBool:working],
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (working) {
        if (self.activityIndicator == nil) {
            self.activityIndicator = ({
                UIActivityIndicatorView *activityIndicator =
                [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                
                activityIndicator.hidesWhenStopped = YES;
                
                [self addSubview:activityIndicator];
                activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterX
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterX
                                                                multiplier:1
                                                                  constant:0]];
                [self addConstraint:[NSLayoutConstraint constraintWithItem:activityIndicator
                                                                 attribute:NSLayoutAttributeCenterY
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:self
                                                                 attribute:NSLayoutAttributeCenterY
                                                                multiplier:1
                                                                  constant:0]];
                
                activityIndicator;
            });
        }
        self.enabled = false;
        [self.activityIndicator startAnimating];
    } else {
        self.enabled = true;
        [self.activityIndicator stopAnimating];
    }
}

- (BOOL)isWorking
{
    NSNumber *temp = objc_getAssociatedObject(self, &kWokingKey);
    return temp.boolValue;
}

+ (UIButton *)createButtonWithTitle:(NSString *)title
                             target:(id)target
                             action:(SEL)action type:(TYPE_COLOR)type {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = kFontSizeNormal;
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    button.layer.cornerRadius = 2.f;
    button.layer.masksToBounds = YES;
    button.layer.borderWidth = .5;
    
    switch (type) {
        case BUTTON_TYPE_RED:{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.borderColor = UIColorFromRGB(BABYCOLOR_base_color).CGColor;
            [button setBackgroundImage:[ImageUtils imageWithColor:UIColorFromRGB(BABYCOLOR_base_color)] forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils imageWithColor:UIColorFromRGB(BABYCOLOR_base_color_pre)] forState:UIControlStateHighlighted];
        }
            break;
        case BUTTON_TYPE_GRAY:{
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            button.layer.borderColor = UIColorFromRGB(BABYCOLOR_gray).CGColor;
            [button setBackgroundImage:[ImageUtils imageWithColor:UIColorFromRGB(BABYCOLOR_gray)] forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils imageWithColor:UIColorFromRGB(BABYCOLOR_gray)] forState:UIControlStateHighlighted];
        }
            break;
        case BUTTON_TYPE_WHITE:{
            [button setTitleColor:UIColorFromRGB(BABYCOLOR_base_color) forState:UIControlStateNormal];
            button.layer.borderColor = UIColorFromRGB(BABYCOLOR_gray).CGColor;
            [button setBackgroundImage:[ImageUtils imageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
            [button setBackgroundImage:[ImageUtils imageWithColor:UIColorFromRGB(BABYCOLOR_gray)] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
    
    
    
    return button;
}

@end
