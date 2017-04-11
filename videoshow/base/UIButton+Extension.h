//
//  UIButton+Extension.h
//  Babypai
//
//  Created by ning on 16/4/22.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "MacroDefinition.h"


@interface UIButton (Extension)

typedef NS_OPTIONS(NSUInteger, TYPE_COLOR) {
    BUTTON_TYPE_RED       = 0,
    BUTTON_TYPE_WHITE  = 1 << 0,
    BUTTON_TYPE_GRAY  = 1 << 1
};

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign, getter=isWorking) BOOL working;

+ (UIButton *)createButtonWithTitle:(NSString *)title
                             target:(id)target
                             action:(SEL)action
                             type:(TYPE_COLOR)type;

- (void)setWorking:(BOOL)working;
- (BOOL)isWorking;

@end
