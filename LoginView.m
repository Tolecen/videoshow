//
//  LoginView.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "LoginView.h"
#import "WXApiManager.h"

@interface LoginView ()

@property (nonatomic, strong) UIImageView *logoImageView;
@property (nonatomic, strong) UIButton *loginBtn;
@property (nonatomic, strong) UIButton *cancelBtn;

@end

@implementation LoginView

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.logoImageView];
        [self addSubview:self.loginBtn];
        [self addSubview:self.cancelBtn];
    }
    return self;
}

- (UIImageView *) logoImageView
{
    if (!_logoImageView) {
        _logoImageView = [[UIImageView alloc] init];
        _logoImageView.frame = CGRectMake(30, 100, MainScreenSize.width - 30*2, 200);
//        _logoImageView.backgroundColor = [UIColor redColor];
        _logoImageView.image = [UIImage imageNamed:@"LoginLogo_1"];
        [_logoImageView sizeToFit];
        _logoImageView.center = CGPointMake(MainScreenSize.width/2, _logoImageView.center.y);
    }
    return _logoImageView;
}

- (UIButton *) cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelBtn.frame = CGRectMake(self.loginBtn.left, self.loginBtn.bottom+10, self.loginBtn.width, self.loginBtn.height);
        [_cancelBtn addTarget:self action:@selector(removeSelf) forControlEvents:UIControlEventTouchUpInside];
        [_cancelBtn setTitle:@"暂不登陆，跳过" forState:UIControlStateNormal];
        [_cancelBtn setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
    }
    return _cancelBtn;
}

- (void) removeSelf
{
    self.cancelLoginBlock?self.cancelLoginBlock():nil;
}

- (UIButton *) loginBtn
{
    if (!_loginBtn) {
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _loginBtn.frame = CGRectMake(60, MainScreenSize.height - 200, MainScreenSize.width - 60*2, 40);
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_loginBtn setTitle:@"微信登陆" forState:UIControlStateNormal];
        
        [_loginBtn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [_loginBtn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
        _loginBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _loginBtn.layer.cornerRadius = 5;
    }
    return _loginBtn;
}

- (void) btnAction:(UIButton *)btn;
{
//    NSLog(@"拉起第三方登陆，登陆成功接收通知隐藏页面");
    self.loginBlock?(self.loginBlock()):nil;
}


@end
