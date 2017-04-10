//
//  BaseTableViewCell.m
//  videoshow
//
//  Created by gutou on 2017/4/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseTableViewCell.h"

@implementation BaseTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void) showActivityIndicatorViewWithView:(id)view stopAnimationHandle:(void (^)(UIActivityIndicatorView *testActivityIndicator))animationHandle
{
    UIActivityIndicatorView *testActivityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    testActivityIndicator.center = ((UIView *)view).center;//只能设置中心，不能设置大小
    [view addSubview:testActivityIndicator];
//    testActivityIndicator.color = [UIColor redColor]; // 改变圈圈的颜色为红色； iOS5引入
    [testActivityIndicator startAnimating]; // 开始旋转
    [testActivityIndicator stopAnimating]; // 结束旋转
    [testActivityIndicator setHidesWhenStopped:YES]; //当旋转结束时隐藏
    
    animationHandle(testActivityIndicator);
}

@end
