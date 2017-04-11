//
//  BabyStartUp.m
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyStartUp.h"
//#import "ViewController.h"

@implementation BabyStartUp

+ (instancetype)appStartUp {
    static BabyStartUp *_appStartUp = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _appStartUp = [[BabyStartUp alloc] init];
    });
    return _appStartUp;
}

- (instancetype)init {
    if (self = [super init]) {
        [self inner_AppStartUp];
    }
    return self;
}

- (void)inner_AppStartUp {
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(BABYCOLOR_base_color)];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:YES];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.f], NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    UIViewController *viewController = [[UIViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:viewController];
    viewController.view.backgroundColor = [UIColor blackColor];
    _rootViewController = navigationController;
}

@end
