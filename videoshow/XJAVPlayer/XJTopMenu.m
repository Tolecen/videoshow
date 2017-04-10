//
//  XJTopMenu.m
//  XJAVPlayer
//
//  Created by xj_love on 2016/10/27.
//  Copyright © 2016年 Xander. All rights reserved.
//

#import "XJTopMenu.h"
#import "UIView+SCYCategory.h"

@interface XJTopMenu ()

@property (nonatomic, strong)UIButton *backButton;
@property (nonatomic, strong)UILabel *titleLabel;

@end

@implementation XJTopMenu

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addAllView];
    }
    return self;
}

- (void)addAllView{
    
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
}

#pragma mark - **************************** 控件事件 *************************************
- (void)goBack{
    if (self.xjTopGoBack) {
        self.xjTopGoBack();
    }
}

#pragma mark - **************************** 懒加载 *************************************
- (UIButton *)backButton{
    if (_backButton == nil) {
        _backButton = [[UIButton alloc] init];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"go_back"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UILabel *)titleLabel{
    if (_titleLabel == nil) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:18];
        _titleLabel.textColor = [UIColor whiteColor];
    }
    return _titleLabel;
}

- (void)setXjAvTitle:(NSString *)xjAvTitle{
    _xjAvTitle = xjAvTitle;
    _titleLabel.text = _xjAvTitle;
}

#pragma mark - **************************** 布局 *************************************
- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (self.xjHidenBackBtn) {
        self.backButton = nil;
    }else{
        self.backButton.frame = CGRectMake(10, 5, 30, 30);
    }
    if (self.xjHidenBackBtn) {
        self.titleLabel.frame = CGRectMake(10, 5 , 200, 30);
    }else{
        self.titleLabel.frame = CGRectMake(50, 5 , 200, 30);
    }
    
    
}

@end
