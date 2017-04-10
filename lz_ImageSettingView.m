//
//  lz_ImageSettingView.m
//  videoshow
//
//  Created by gutou on 2017/3/11.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_ImageSettingView.h"

@interface lz_ImageSettingView ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *tapAndPanImageView;

@end

@implementation lz_ImageSettingView

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype) initWithFrame:(CGRect)frame withImage:(UIImage *)image;
{
    if ([super initWithFrame:frame]) {
        
        
    }
    return self;
}




@end
