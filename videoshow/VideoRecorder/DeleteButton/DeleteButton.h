//
//  DeleteButton.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    DeleteButtonStyleDelete,
    DeleteButtonStyleNormal,
    DeleteButtonStyleDisable,
}DeleteButtonStyle;

@interface DeleteButton : UIButton

@property (assign, nonatomic) DeleteButtonStyle style;

- (void)setButtonStyle:(DeleteButtonStyle)style;

@end