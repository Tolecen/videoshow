//
//  CellTheme.m
//  Babypai
//
//  Created by ning on 16/5/6.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "CellTheme.h"
#import "UIImageView+WebCache.h"
#import "StringUtils.h"

@interface CellTheme()

@property (weak, nonatomic) UIImageView *image;
@property (weak, nonatomic) UILabel *text;

@end

@implementation CellTheme

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    UIImageView *image = [[UIImageView alloc]init];
    _image = image;
    
    UIImageView *selectedView = [[UIImageView alloc]init];
    _selectedView = selectedView;
    
    UILabel *text = [[UILabel alloc]init];
    text.font = kFontSizeSmall;
    text.textColor = [UIColor whiteColor];
    text.textAlignment = NSTextAlignmentCenter;
    _text = text;
    
    [self.contentView sd_addSubviews:@[_image, _selectedView, _text]];
    
    _image.sd_layout
    .widthIs(CELL_THEME_IMAGE_WH)
    .heightIs(CELL_THEME_IMAGE_WH)
    .leftSpaceToView(self.contentView, (CELL_THEME_W - CELL_THEME_IMAGE_WH) / 2)
    .topSpaceToView(self.contentView, 6);
    
    _selectedView.sd_layout
    .widthIs(CELL_THEME_IMAGE_WH)
    .heightIs(CELL_THEME_IMAGE_WH)
    .leftSpaceToView(self.contentView, (CELL_THEME_W - CELL_THEME_IMAGE_WH) / 2)
    .topSpaceToView(self.contentView, 6);
    
    _text.sd_layout
    .widthIs(CELL_THEME_W)
    .heightIs(20)
    .topSpaceToView(_image, 4);
    
}

- (void)setTheme:(VideoTheme *)theme
{
    _theme = theme;
    if (![StringUtils isEmpty:theme.themeIconResource]) {
        _image.image = ImageNamed(theme.themeIconResource);
    } else if (![StringUtils isEmpty:theme.themeIcon]) {
//        [_image sd_setImageWithURL:[NSURL URLWithString:theme.themeIcon]];
        _image.image = [UIImage imageWithContentsOfFile:theme.themeIcon];
    }
    
    if (theme.isMv) {
        _selectedView.image = ImageNamed(@"record_theme_selected");
    } else {
        _selectedView.image = ImageNamed(@"record_theme_square_selected");
    }
    
    _text.text = theme.themeDisplayName;
}

@end
