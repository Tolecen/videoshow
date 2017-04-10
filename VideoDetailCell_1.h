//
//  VideoDetailCell_1.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class lz_VideoTemplateModel;

@interface VideoDetailCell_1 : UICollectionViewCell


@property (nonatomic, strong) lz_VideoTemplateModel *model;

+ (CGFloat)cellHeightWithData:(NSString *)data;

@end
