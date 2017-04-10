//
//  lz_VideoTemplateListVC.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseCollectionViewController.h"

typedef void(^didSelectedBlock)(NSDictionary *dict);

//视频模板页面下方视频展示部分
@interface lz_VideoTemplateListVC : BaseCollectionViewController

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, copy) didSelectedBlock didSelectBlock;

@end
