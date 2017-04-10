//
//  InstructionTableVC.m
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_InstructionTableVC.h"
#import "lz_IntroDetailViewController.h"

@interface lz_InstructionTableVC ()

@property (nonatomic, strong) NSArray *titleArr;

@end

@implementation lz_InstructionTableVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showBackItem];
    
    self.title = @"使用说明";
    
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    
    self.titleArr = [NSArray arrayWithObjects:@"视频编辑小技巧1",@"视频编辑小技巧2",@"视频编辑小技巧3",@"视频编辑小技巧4",@"视频编辑小技巧5",@"视频编辑小技巧6", nil];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.titleArr.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = self.titleArr[indexPath.item];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    lz_IntroDetailViewController *vc = [[lz_IntroDetailViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) requestRefresh
{
    [self finishRequest];
}

- (void) requestGetMore
{
    [self finishRequest];
}

@end
