//
//  lz_MyCollectionCell.h
//  videoshow
//
//  Created by gutou on 2017/3/20.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewCell.h"

@class lz_VideoTemplateModel;
//我的收藏cell
@interface lz_MyCollectionCell : BaseTableViewCell

+ (instancetype) cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *) reuseIdentifier indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) lz_VideoTemplateModel *model;

+ (CGFloat)cellHeightWithData:(NSString *)data;

@end
