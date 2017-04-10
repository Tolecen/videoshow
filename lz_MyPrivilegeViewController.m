//
//  lz_MyPrivilegeViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_MyPrivilegeViewController.h"
#import "lz_TopupVIPViewController.h"

@interface lz_MyPrivilegeViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UIImageView *userTagImageView;
@property (weak, nonatomic) IBOutlet UILabel *userTagLab;
@property (weak, nonatomic) IBOutlet UILabel *userTimeLab;

@property (weak, nonatomic) IBOutlet UITextView *IntroTextView;
@property (weak, nonatomic) IBOutlet UIButton *userBtn;

@end

@implementation lz_MyPrivilegeViewController

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"我的特权";
    [self showBackItem];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)btnAction_1:(id)sender {
    lz_TopupVIPViewController *vc = [[lz_TopupVIPViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
