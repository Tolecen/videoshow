//
//  BaseShareViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/3.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseShareViewController.h"


@interface BaseShareViewController ()

@property (nonatomic, strong) NSArray       *images;
@property (nonatomic, strong) NSArray       *titles;

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation BaseShareViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [AppAppearance sharedAppearance].alertBackgroundColor;
    
    self.backgroundView = [UIView new];
    self.backgroundView.frame = CGRectMake(0, MainScreenSize.height, MainScreenSize.width, MainScreenSize.width/10+44+20+30);
    self.backgroundView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.backgroundView];
    
    //自定义icon
    self.images = @[@"umsocial_wechat_timeline",@"umsocial_wechat",@"umsocial_qq",@"umsocial_qzone",@"umsocial_sina"];
    self.titles = @[@"微信朋友圈",@"微信好友",@"QQ好友",@"QQ空间",@"新浪微博",];
    
        
    [self.images enumerateObjectsUsingBlock:^(NSString * obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        [btn setBackgroundImage:[UIImage imageNamed:obj] forState:UIControlStateNormal];
        btn.frame = CGRectMake(0 , 10, MainScreenSize.width/10, MainScreenSize.width/10);
//        [btn sizeToFit];
        btn.layer.cornerRadius = btn.width/2;
        
        btn.tag = idx;
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.backgroundView addSubview:btn];
        
        UILabel *lab = [UILabel new];
        lab.text = self.titles[idx];
        lab.tintColor = [UIColor lightTextColor];
        lab.textAlignment = NSTextAlignmentCenter;
        lab.font = [UIFont systemFontOfSize:12];
        lab.frame = CGRectMake(0 + idx*MainScreenSize.width/5, btn.bottom, MainScreenSize.width/5, 20);
        [self.backgroundView addSubview:lab];
        btn.center = CGPointMake(lab.center.x, btn.center.y);
        
    }];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    cancelBtn.backgroundColor = [UIColor whiteColor];
    [cancelBtn addTarget:self action:@selector(hideView) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.frame = CGRectMake(0, MainScreenSize.width/10+20+20, MainScreenSize.width, 44);
    [self.backgroundView addSubview:cancelBtn];
}

- (void) shareToPlatform:(UMSocialPlatformType)platformType
           messageObject:(UMSocialMessageObject *)messageObject
   currentViewController:(id)currentViewController;
{
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:currentViewController completion:^(id data, NSError *error) {
        
        if (self.ShareMessageBlock) {
            self.ShareMessageBlock(data,error);
        }
        
        if (error) {
            
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                
                UMSocialShareResponse *resp = data;
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
        NSLog(@"error = %@",error);
    }];
}

- (void) btnAction:(UIButton *)btn
{
    NSInteger index = btn.tag;

    UMSocialPlatformType platformType;
    switch (index) {
        case 0:
        {
            platformType = UMSocialPlatformType_WechatTimeLine;
        }
            break;
        case 1:
        {
            platformType = UMSocialPlatformType_WechatSession;
        }
            break;
        case 2:
        {
            platformType = UMSocialPlatformType_QQ;
        }
            break;
        case 3:
        {
            platformType = UMSocialPlatformType_Qzone;
        }
            break;
        case 4:
        {
            platformType = UMSocialPlatformType_Sina;
        }
            break;
        default:
            break;
    }
    
    [self shareToPlatform:platformType messageObject:self.messageObject currentViewController:nil];
}

- (void) showWithViewController:(id)viewController;
{
    [[UIApplication sharedApplication].keyWindow addSubview:self.view];
    [viewController addChildViewController:self];
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.alpha = 1;
        self.backgroundView.frame = CGRectMake(self.backgroundView.left, MainScreenSize.height-self.backgroundView.height, MainScreenSize.width, self.backgroundView.height);
    } completion:^(BOOL finished) {
        
    }];
}

- (void) hideView
{
    [UIView animateWithDuration:0.3 animations:^{
        
        self.view.alpha = 0;
        self.backgroundView.frame = CGRectMake(self.backgroundView.left, MainScreenSize.height, MainScreenSize.width, self.backgroundView.height);
    } completion:^(BOOL finished) {
        [self.view removeFromSuperview];
    }];
}


@end
