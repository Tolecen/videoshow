//
//  LZ_BasePlayerViewController.m
//  videoshow
//
//  Created by gutou on 2017/4/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "LZ_BasePlayerViewController.h"
#import "XjAVPlayerSDK.h"

@interface LZ_BasePlayerViewController ()<XjAVPlayerSDKDelegate>{
    XjAVPlayerSDK *myPlayer;
}
@end

@implementation LZ_BasePlayerViewController

- (BOOL) shouldAutorotate
{
    return NO;
}

//支持右横屏
- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    if (!self.playerUrl.length) {
        [self xjGoBack];
        return;
    }
    
    myPlayer = [[XjAVPlayerSDK alloc] initWithFrame:CGRectMake(0, 0, MainScreenSize.height, MainScreenSize.width)];
    myPlayer.xjPlayerUrl = self.playerUrl;
    myPlayer.xjPlayerTitle = @"在线视频";
    myPlayer.xjAutoOrient = NO;
    myPlayer.XjAVPlayerSDKDelegate = self;
    myPlayer.xjLastTime = 50;
    
    [self.view addSubview:myPlayer];
}

- (void)xjGoBack{
    [myPlayer xjStopPlayer];
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
