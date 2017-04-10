//
//  lz_UpdateViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^UpdateBlock)(NSInteger index);

@interface lz_UpdateViewController : BaseViewController

@property (nonatomic, strong) UIView * headerView;

@property (nonatomic, copy) UpdateBlock UpdateBlock;

@end
