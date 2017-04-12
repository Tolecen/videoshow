//
//  ViewController.m
//  videoshow
//
//  Created by mapboo on 27/02/2017.
//  Copyright © 2017 mapboo. All rights reserved.
//

#import "HomeViewController.h"
#import "lz_VideoTemplateBaseVC.h"
#import "lz_InstructionTableVC.h"
#import "UserCenterViewController.h"
#import "lz_WatermarkBaseViewController.h"

#import "VS_AlertVC_Logout.h"

#import "lz_VideoTemplateModel.h"
#import "UserModel.h"
#import "LoginModel.h"
#import "VideoRecorderViewController.h"

#import "KouBeijingSelectVideoViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (instancetype) init
{
    if ([super init]) {
        self = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
        //375*667 适配合适
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userBtn setTitle:[AppDataManager defaultManager].name forState:UIControlStateNormal];
    [userBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//    [userBtn setImage:[UIImage imageWithData:[AppDataManager defaultManager].user_image] forState:UIControlStateNormal];
    userBtn.backgroundColor = [UIColor whiteColor];
    userBtn.layer.cornerRadius = 25;
//    [userBtn setTitle:@"个人中心" forState:UIControlStateNormal];
    userBtn.frame = CGRectMake(20, 140, 200, 50);
    userBtn.center = CGPointMake(MainScreenSize.width/2, userBtn.center.y);
    [userBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:userBtn];

    
    //如果在审核期间没有真实账户，那就启动测试账户
    if (![AppDataManager defaultManager].identifier.length) {
        [self requestTestLoginModel];
    }
    
    //启动动画
    [UserModel requestAdSplashDataWithSuccessHandle:^(id responseObject) {
                
        //开辟异步线程执行下载任务
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            //这一步最卡 在3g模式下大概会持续 4-5 分钟
//                NSLog(@"url = %@",[NSURL URLWithString:obj.ImageSrc]);
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:responseObject[@"image_url"]]];
            [responseObject setValue:imageData forKey:@"imageData"];
            [[AppDataManager defaultManager] setAdDic:responseObject];
        });
    } FailureHandle:^(NSError *error) {
        
    }];
}

//审核模式下请求测试信息
- (void) requestTestLoginModel
{
    [LoginModel testGetLoginCodeWithSuccessHandle:^(id responseObject) {
        
        //根据测试code模拟登陆
        [LoginModel loginWithCode:responseObject[@"code"] SuccessHandle:^(id responseObject) {
            
        } FailureHandle:^(NSError *error) {
            NSLog(@"debug模式登陆失败");
        }];
    } FailureHandle:^(NSError *error) {
        NSLog(@"release模式");
    }];
}

- (void) leftAction:(UIButton *)barItem
{
    NSLog(@"个人中心");
    if (![AppDataManager defaultManager].hasLogin) {

        [self showLoginViewControllerWithCurrentViewController:self];
        return;
    }
    UserCenterViewController *vc = [UserCenterViewController new];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)Action_0:(UIButton *)sender {
    
    NSLog(@"十秒模板");
    lz_VideoTemplateBaseVC *vc = [[lz_VideoTemplateBaseVC alloc] init];
    vc.Template_Type = Template_Short;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)Action_1:(id)sender {
    
    NSLog(@"长视频模板");
    lz_VideoTemplateBaseVC *vc = [[lz_VideoTemplateBaseVC alloc] init];
    vc.Template_Type = Template_Long;
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)Action_2:(id)sender {
    NSLog(@"乾坤大挪移");
    if (![AppDataManager defaultManager].hasLogin) {
        
        [self showLoginViewControllerWithCurrentViewController:self];
        
        [self HudShowWithStatus:@"请登录" Delay:1.5];
        return;
    }
    //拉起支付平台
//    [lz_VideoTemplateModel requestTemplateChargeWithTemplateID:[NSNumber numberWithInteger:101] pay_type:@"wxpay" SuccessHandle:^(id responseObject) {
//        
//    } FailureHandle:^(NSError *error) {
//        
//    }];
//    
    
    KouBeijingSelectVideoViewController *camera = [[KouBeijingSelectVideoViewController alloc] init];
    [self.navigationController pushViewController:camera animated:YES];
}
- (IBAction)Action_3:(id)sender {
    
    NSLog(@"分段拍摄");
    if (![AppDataManager defaultManager].hasLogin) {
        
        [self showLoginViewControllerWithCurrentViewController:self];
        
        [self HudShowWithStatus:@"请登录" Delay:1.5];
        return;
    }
    VideoRecorderViewController *camera = [[VideoRecorderViewController alloc] init];
    [self.navigationController pushViewController:camera animated:YES];
//    UINavigationController *cameraNav = [[UINavigationController alloc]initWithRootViewController:camera];
//    [self presentViewController:cameraNav animated:YES completion:nil];
}
- (IBAction)Action_4:(id)sender {
    NSLog(@"水印视频");
    
    if (![AppDataManager defaultManager].hasLogin) {
        
        [self showLoginViewControllerWithCurrentViewController:self];
        
        [self HudShowWithStatus:@"请登录" Delay:1.5];
        return;
    }
    lz_WatermarkBaseViewController *vc = [[lz_WatermarkBaseViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}
- (IBAction)Action_6:(id)sender {
   
    NSLog(@"使用说明");
    lz_InstructionTableVC *vc = [[lz_InstructionTableVC alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}



@end
