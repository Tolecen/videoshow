//
//  AdViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AdViewController.h"
#import "UserModel.h"

@interface AdViewController ()

@end

@implementation AdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    [self.view addSubview:self.adView];
}


-(AdView *)adView
{
    if (_adView == nil) {
        _adView = [[AdView alloc] initWithFrame:self.view.bounds];
    }
    return _adView;
}

@end
