//
//  lz_MyWaterMarkViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^MyWaterMarkBlock)(void);

@interface lz_MyWaterMarkViewController : BaseViewController

@property (nonatomic, strong) UIView * headerView;

@property (nonatomic, copy) MyWaterMarkBlock MyWaterMarkBlock;

@property (nonatomic, assign) NSInteger type_Index;//先显示文字水印还是图片水印

- (void) showPicOrText:(NSInteger)type_Index;

@end
