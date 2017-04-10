//
//  lz_TopupVIPViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_TopupVIPViewController.h"

@interface lz_TopupVIPViewController ()

@property (weak, nonatomic) IBOutlet UILabel *userNameLab;

@property (weak, nonatomic) IBOutlet UIButton *payBtn;

@end

@implementation lz_TopupVIPViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"充值会员";
    [self showBackItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)payBtnAction_1:(id)sender {
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
