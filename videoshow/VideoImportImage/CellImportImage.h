//
//  CellImportImage.h
//  Babypai
//
//  Created by ning on 16/5/17.
//  Copyright © 2016年 Babypai. All rights reserved.
//
#import <UIKit/UIKit.h>

@interface CellImportImage : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *deleteBtn;
@property (nonatomic, assign) NSInteger row;

- (UIView *)snapshotView;


@end
