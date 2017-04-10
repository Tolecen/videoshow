//
//  lz_UpdateViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_UpdateViewController.h"

#import "VS_Choose_AlertView.h"

@interface lz_UpdateViewController ()

@end

@implementation lz_UpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    NSArray *arr = @[@"上传本地视频",@"下载",@"一键加水印",];
    NSArray *imageArr = @[[UIImage imageNamed:@"water_update"],[UIImage imageNamed:@"xiazai"],[UIImage imageNamed:@"water_camera"],];
    
    
    CGFloat btnW = MainScreenSize.width/5;
    CGFloat x = (MainScreenSize.width - btnW*3)/6;
    for (NSInteger i = 0; i < 3; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setImage:imageArr[i] forState:UIControlStateNormal];
        [btn sizeToFit];
        btn.frame = CGRectMake(x + (btnW+x*2) * i, 20, btnW, btnW);
        btn.tag = 10 + i;
        [btn addTarget:self action:@selector(action:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        
        UILabel *lab = [UILabel new];
        [lab setTextColor:[UIColor blackColor]];
        [lab setText:arr[i]];
        lab.font = [UIFont systemFontOfSize:13];
        lab.frame = CGRectMake(0, btn.bottom, 60, 20);
        [lab sizeToFit];
        lab.center = CGPointMake(btn.center.x, lab.center.y);
        [self.view addSubview:lab];
    }
}

- (void) action:(UIButton *)btn
{
    if (btn.tag == 10) {
        
        //上传视频
        [self HudShowWithStatus:@"上传"];
    }else if (btn.tag == 11){
        //下载
        [self HudShowWithStatus:@"下载"];
    }else {
        
        //一键加水印
        VS_Choose_AlertView *view = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        view.block = ^(WaterMarkType type) {
            if (type == WaterMarkType_PicWaterMark) {
                
                //跳转图片加水印
                self.UpdateBlock(1);
            }else if (type == WaterMarkType_TextWaterMark) {
                
                //跳转文字加水印
                self.UpdateBlock(0);
            }else {
                
            }
        };
        [view show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
