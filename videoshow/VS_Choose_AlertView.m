//
//  VS_Choose_AlertView.m
//  videoshow
//
//  Created by gutou on 2017/3/20.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VS_Choose_AlertView.h"

@interface VS_Choose_AlertView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIButton *topBtn;
@property (nonatomic, strong) UIButton *bottomBtn;

@end

@implementation VS_Choose_AlertView

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.alpha = 0;
        self.backgroundColor = [AppAppearance sharedAppearance].alertBackgroundColor;
        
        [self addSubview:self.backgroundImageView];
        [self.backgroundImageView addSubview:self.topBtn];
        UIView *line = [UIView new];
        line.frame = CGRectMake(self.topBtn.left, self.topBtn.bottom, self.topBtn.width, 1);
        line.backgroundColor = UIColorFromRGB(0x929292);
        [self.backgroundImageView addSubview:line];
        [self.backgroundImageView addSubview:self.bottomBtn];
    }
    return self;
}

- (UIImageView *) backgroundImageView
{
    if (!_backgroundImageView) {
        _backgroundImageView = [[UIImageView alloc] init];
        _backgroundImageView.image = [UIImage imageNamed:@"alert_background_2"];
        _backgroundImageView.userInteractionEnabled = YES;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        [_backgroundImageView sizeToFit];
        _backgroundImageView.center = CGPointMake(MainScreenSize.width/2, MainScreenSize.height/2);
    }
    return _backgroundImageView;
}

- (UIButton *) topBtn
{
    if (!_topBtn) {
        _topBtn = [self createButton];
        [_topBtn setTitle:@"文字水印" forState:UIControlStateNormal];
        _topBtn.frame = CGRectMake(0, self.backgroundImageView.height/3, self.backgroundImageView.width, self.backgroundImageView.height/3);
        _topBtn.tag = 11;
        [_topBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _topBtn;
}

- (UIButton *) bottomBtn
{
    if (!_bottomBtn) {
        _bottomBtn = [self createButton];
        [_bottomBtn setTitle:@"图片水印" forState:UIControlStateNormal];
        _bottomBtn.frame = CGRectMake(0, self.backgroundImageView.height/3*2+1, self.backgroundImageView.width, self.backgroundImageView.height/3);
        _bottomBtn.tag = 12;
        [_bottomBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomBtn;
}

- (void) setTitles:(NSArray *)titles;
{
    if (titles.count) {
        [_topBtn setTitle:titles.firstObject forState:UIControlStateNormal];
        if ([titles.lastObject isEqualToString:@"提交生成"]) {
            [_bottomBtn setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
        }
        [_bottomBtn setTitle:titles.lastObject forState:UIControlStateNormal];
    }
}

- (UIButton *) createButton
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:18];
    
    return btn;
}

- (void) btnAction:(UIButton *)btn
{
    if (btn.tag == 11) {
        
        self.block(WaterMarkType_TextWaterMark);
    }else if (btn.tag == 12) {
        self.block(WaterMarkType_PicWaterMark);
    }else {
        
    }
    [self hide];
}

- (void) show;
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hide;
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void) touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [touches.allObjects.lastObject locationInView:self.superview];
    
    //如果触摸点不在中间，消失
    if (!CGRectContainsPoint(self.backgroundImageView.frame, point)) {
        [self hide];
    }
}

@end
