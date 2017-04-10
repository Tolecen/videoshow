//
//  VS_AlertVC_Logout.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VS_AlertVC_Logout.h"

@interface VS_AlertVC_Logout ()

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *showView;

@end

@implementation VS_AlertVC_Logout

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.frame = [UIScreen mainScreen].bounds;
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    _backgroundView = [UIView new];
    _backgroundView.backgroundColor = [AppAppearance sharedAppearance].alertBackgroundColor;
    _backgroundView.alpha = 0;
    _backgroundView.frame = [UIScreen mainScreen].bounds;
    [self addSubview:_backgroundView];
    
    _showView = [UIView new];
    _showView.backgroundColor = [UIColor whiteColor];
    [_backgroundView addSubview:_showView];
    _showView.frame = CGRectMake(0, MainScreenSize.height+128, MainScreenSize.width, 128);
    
    UILabel *lab = [UILabel new];
    lab.text = @"退出登录后不会清楚任何历史数据";
    lab.textColor = UIColorFromRGB(0x808081);
    lab.font = [UIFont systemFontOfSize:10];
    lab.textAlignment = NSTextAlignmentCenter;
    [_showView addSubview:lab];
    [lab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_showView.mas_left).offset(0);
        make.right.equalTo(_showView.mas_right).offset(0);
        make.top.equalTo(_showView.mas_top).offset(0);
        make.height.mas_equalTo(23);
    }];
    
    UIView *line = [UIView new];
    line.backgroundColor = [UIColor lightGrayColor];
    [_showView addSubview:line];
    [line mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_showView.mas_left).offset(0);
        make.right.equalTo(_showView.mas_right).offset(0);
        make.top.equalTo(lab.mas_bottom).offset(0);
        make.height.mas_equalTo(0.5);
    }];
    
    UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn1 setTitle:@"退出登录" forState:UIControlStateNormal];
    [btn1 setTitleColor:UIColorFromRGB(0xdb0000) forState:UIControlStateNormal];
    btn1.titleLabel.font = [UIFont systemFontOfSize:16];
    btn1.tag = 1001;
    [btn1 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_showView addSubview:btn1];
    [btn1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_showView.mas_left).offset(0);
        make.right.equalTo(_showView.mas_right).offset(0);
        make.top.equalTo(line.mas_bottom).offset(0);
        make.height.mas_equalTo(49);
    }];
    
    UIView *line2 = [UIView new];
    line2.backgroundColor = [UIColor lightGrayColor];
    [_showView addSubview:line2];
    [line2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_showView.mas_left).offset(0);
        make.right.equalTo(_showView.mas_right).offset(0);
        make.top.equalTo(btn1.mas_bottom).offset(0);
        make.height.mas_equalTo(6.5);
    }];
    
    UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn2 setTitle:@"取消" forState:UIControlStateNormal];
    [btn2 setTitleColor:UIColorFromRGB(0x0d0d0d) forState:UIControlStateNormal];
    btn2.titleLabel.font = btn1.titleLabel.font;
    btn2.tag = 1002;
    [btn2 addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    [_showView addSubview:btn2];
    [btn2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_showView.mas_left).offset(0);
        make.right.equalTo(_showView.mas_right).offset(0);
        make.top.equalTo(line2.mas_bottom).offset(0);
        make.bottom.equalTo(_showView.mas_bottom).offset(0);
    }];
}

- (void) btnAction:(UIButton *)btn
{
    if (btn.tag == 1002) {
        
            [self hide];
    }else {
        
        if (self.block) {
            self.block(btn);
            [self hide];
        }
    }
}

- (void) setBlock:(VS_AlertVC_Logout_Block)block
{
    _block = block;
}

- (void) show;
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.45 animations:^{
        _backgroundView.alpha = 1;
        _showView.frame = CGRectMake(0, MainScreenSize.height-128, MainScreenSize.width, 128);
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hide;
{
    [UIView animateWithDuration:0.45 animations:^{
        _backgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.000];
        _showView.frame = CGRectMake(0, MainScreenSize.height, MainScreenSize.width, 128);
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) touchesBegan:(NSSet*)touches withEvent:(UIEvent *)event
{
    //    UITouch *touch = touches.anyObject;
    //    CGPoint touchPoint = [touch locationInView:self];
}



@end
