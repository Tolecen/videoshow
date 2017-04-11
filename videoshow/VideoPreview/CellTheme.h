//
//  CellTheme.h
//  Babypai
//
//  Created by ning on 16/5/6.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyTableViewCell.h"
#import "VideoTheme.h"

#define CELL_THEME_H 90
#define CELL_THEME_W 70
#define CELL_THEME_IMAGE_WH 56

@interface CellTheme : BabyTableViewCell

@property(nonatomic, strong) VideoTheme *theme;
@property (nonatomic, assign)NSInteger cellIndex;

@property(nonatomic, strong) UIImageView *selectedView;

@end
