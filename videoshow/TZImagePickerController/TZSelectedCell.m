//
//  TZSelectedCell.m
//  TZImagePickerController
//
//  Created by ning on 16/5/3.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import "TZSelectedCell.h"
#import "UIView+Layout.h"
#import "TZImageManager.h"
#import "TZImagePickerController.h"

@interface TZSelectedCell()

@property (weak, nonatomic) UIImageView *image;       // The photo / 照片
@property (weak, nonatomic) UIButton *selectPhotoButton;

@end

@implementation TZSelectedCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

- (void)setModel:(TZAssetModel *)model
{
    _model = model;
    [[TZImageManager manager] getPhotoWithAsset:model.asset photoWidth:self.tz_width completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        self.imageView.image = photo;
    }];
    self.selectPhotoButton.selected = model.isSelected;
}

#pragma mark - Lazy load

- (UIButton *)selectPhotoButton {
    
    
    if (_selectPhotoButton == nil) {
        UIButton *selectImageView = [[UIButton alloc] init];
        selectImageView.frame = CGRectMake(56, 6, 26, 26);
        [selectImageView addTarget:self action:@selector(selectPhotoButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [selectImageView setImage:[UIImage imageNamedFromMyBundle:@"icon_close_nor.png"] forState:UIControlStateNormal];
        [selectImageView setImage:[UIImage imageNamedFromMyBundle:@"icon_close_pre.png"] forState:UIControlStateHighlighted];
        [self.contentView addSubview:selectImageView];
        _selectPhotoButton = selectImageView;
    }
    return _selectPhotoButton;
}

- (UIImageView *)imageView {
    
    if (_image == nil) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(4, 4, 80, 80);
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [self.contentView addSubview:imageView];
        _image = imageView;
    }
    return _image;
}

- (void)selectPhotoButtonClick:(UIButton *)sender {
    if (self.removeSelectedPhotoBlock) {
        self.removeSelectedPhotoBlock();
    }
}

@end
