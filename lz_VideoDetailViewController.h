//
//  lz_VideoDetailViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"


typedef enum : NSUInteger {
    MyController_UseTemplate,//使用模板页面
    MyController_ShareTemplate,//分享模板页面
    MyController_OtherTemplate,
} MyController_Template_Type;
@interface lz_VideoDetailViewController : BaseViewController

@property (nonatomic, strong) NSDictionary *dict;//传递进来的数据

@property (nonatomic, assign) MyController_Template_Type MyController_Type;

@end
