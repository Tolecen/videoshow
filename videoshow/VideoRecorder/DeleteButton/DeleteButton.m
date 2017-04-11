//
//  DeleteButton.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "DeleteButton.h"

#define DELETE_BTN_NORMAL_IAMGE @"record_undo_button"
#define DELETE_BTN_NORMAL_H_IAMGE @"record_undo_button_pressed"
#define DELETE_BTN_DELETE_IAMGE @"record_delete_button"
#define DELETE_BTN_DELETE_H_IAMGE @"record_delete_button_pressed"
#define DELETE_BTN_DISABLE_IMAGE @"record_undo_button_pressed"

@interface DeleteButton ()


@end

@implementation DeleteButton

- (id)init
{
    self = [super init];
    if (self) {
        [self initalize];
    }
    return self;
}

- (void)initalize
{
    [self setImage:[UIImage imageNamed:DELETE_BTN_NORMAL_IAMGE] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:DELETE_BTN_NORMAL_H_IAMGE] forState:UIControlStateHighlighted];
    [self setImage:[UIImage imageNamed:DELETE_BTN_DISABLE_IMAGE] forState:UIControlStateDisabled];
}

- (void)setButtonStyle:(DeleteButtonStyle)style
{
    self.style = style;
    switch (style) {
        case DeleteButtonStyleNormal:
        {
            self.enabled = YES;
            [self setImage:[UIImage imageNamed:DELETE_BTN_NORMAL_IAMGE] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:DELETE_BTN_NORMAL_H_IAMGE] forState:UIControlStateHighlighted];
        }
            break;
        case DeleteButtonStyleDisable:
        {
            self.enabled = NO;
        }
            break;
        case DeleteButtonStyleDelete:
        {
            self.enabled = YES;
            [self setImage:[UIImage imageNamed:DELETE_BTN_DELETE_IAMGE] forState:UIControlStateNormal];
            [self setImage:[UIImage imageNamed:DELETE_BTN_DELETE_H_IAMGE] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
}

@end
