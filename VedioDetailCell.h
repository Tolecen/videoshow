//
//  VedioDetailCell.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@class lz_VideoTemplateModel;

typedef void(^VedioDetailCell_deleteDataBlock)(lz_VideoTemplateModel *model);

//我的作品cell
@interface VedioDetailCell : BaseTableViewCell

+ (instancetype) cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *) reuseIdentifier indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) lz_VideoTemplateModel *model;

@property (nonatomic, copy) VedioDetailCell_deleteDataBlock VedioDetailCell_deleteDataBlock;//

+ (CGFloat)cellHeightWithData:(NSString *)data;


@end
