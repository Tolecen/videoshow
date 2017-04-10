//
//  lz_VideoTemplateBaseVC.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"

typedef enum : NSUInteger {
    Template_Short,
    Template_Long,
    Template_Other,
} Template_Type;


//视频模板vc
@interface lz_VideoTemplateBaseVC : BaseViewController

@property (nonatomic, assign) Template_Type Template_Type;

@end
