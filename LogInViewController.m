//
//  LogInViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "LogInViewController.h"
#import "WXApiManager.h"
#import "LoginModel.h"

@interface LogInViewController ()<WXApiManagerDelegate>

@end

@implementation LogInViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (BOOL) prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [WXApiManager sharedManager].delegate = self;
    
    _loginView = [[LoginView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    [self.view addSubview:self.loginView];
    
    WeakTypeof(weakSelf)
    _loginView.loginBlock = ^(void) {
        [weakSelf loginAction];
    };
    
    _loginView.cancelLoginBlock = ^(void) {
        [weakSelf hide];
    };
}

//登陆
- (void) loginAction
{
    if (![WXApiManager isWXAppInstalled]) {
        
        [SVProgressHUD showWithStatus:@"请安装微信客户端"];
        [SVProgressHUD dismissWithDelay:1];
        
        [self hide];
        return;
    }
    
    [WXApiManager sendAuthRequestScope:@"snsapi_userinfo"
                                 State:@"wx_test"
                                OpenID:WX_AppKey
                      InViewController:self];
}

- (void) managerDidRecvAuthResponse:(SendAuthResp *)response {
//    NSString *strTitle = [NSString stringWithFormat:@"Auth结果"];
//    NSString *strMsg = [NSString stringWithFormat:@"code:%@,state:%@,errcode:%d", response.code, response.state, response.errCode];
//    NSLog(@"strMsg = %@",strMsg);
    
    if (response.code) {
       [self requestDataWithCode:response.code];
    }else {
        [SVProgressHUD showErrorWithStatus:@"取消登陆"];
    }

    [self hide];
}

- (void) requestDataWithCode:(NSString *)code
{
    [LoginModel loginWithCode:code
                SuccessHandle:^(id responseObject) {
                    
                    [SVProgressHUD showWithStatus:responseObject[@"message"]];
                    [SVProgressHUD dismissWithDelay:1.5];
                                        
                } FailureHandle:^(NSError *error) {
                    [SVProgressHUD showWithStatus:@"登陆失败"];
                    [SVProgressHUD dismissWithDelay:1];
                }];
}

- (void) hide
{
    [UIView animateWithDuration:0.68 animations:^{
        self.view.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}

@end
