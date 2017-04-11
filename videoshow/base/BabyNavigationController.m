//
//  BabyNavigationController.m
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyNavigationController.h"

@interface BabyNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@property (assign, nonatomic) BOOL isSwitching;

@end

@implementation BabyNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.interactivePopGestureRecognizer.delegate = self;
}

//// 重载 push 方法
//- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    if (animated) {
//        if (self.isSwitching) {
//            return; // 1. 如果是动画，并且正在切换，直接忽略
//        }
//        self.isSwitching = YES; // 2. 否则修改状态
//    }
//    self.interactivePopGestureRecognizer.enabled = NO;
//    [super pushViewController:viewController animated:animated];
//}
//
//#pragma mark - UINavigationControllerDelegate
//
//- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
//    self.isSwitching = NO; // 3. 还原状态
//    self.interactivePopGestureRecognizer.enabled = YES;
//}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

@end
