//
//  UserCenterViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "UserCenterViewController.h"
#import "lz_VideoListTableViewController.h"
#import "lz_MyPrivilegeViewController.h"
#import "lz_MyWaterMarkViewController.h"

#import "lz_UserCenterTopPic.h"
#import "VS_AlertVC_Logout.h"

#import "UserModel.h"

#define HeaderViewHeight (MainScreenSize.height * 0.26)

@interface UserCenterViewController ()

@property (nonatomic, strong) NSArray *cellTitles;
@property (nonatomic, strong) NSArray *cellImages;

@property (nonatomic, strong) lz_UserCenterTopPic *headerView;

@end

@implementation UserCenterViewController

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"个人中心";
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    self.tableView.scrollEnabled = NO;
    self.tableView.tableHeaderView = self.headerView;
    self.tableView.tableFooterView = [self setup_layoutBtn];
    
    UIButton *userBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [userBtn setImage:[UIImage imageNamed:@"item_back"] forState:UIControlStateNormal];
    userBtn.frame = CGRectMake(0, 10, 50, 44);
//    [userBtn sizeToFit];
    [userBtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside];
    [self.tableView.tableHeaderView addSubview:userBtn];
    
    
    self.cellTitles = @[@"我的收藏",@"我的作品",@"我的水印",@"我的特权",@"邀请好友",@"使用说明",@"常见问题",@"关于我们",];
    self.cellImages = @[@"wo_04",@"wo_11",@"wo_14",@"wo_13",@"wo_15",@"wo_17",@"wo_19",@"wo_21",];
    
    [self requestRefresh];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestRefresh) name:appDidLogoutNotification object:nil];
}

- (void) requestRefresh
{
    //个人信息
    [UserModel requestUserInfoWithSuccessHandle:^(id responseObject) {
        
        _headerView.datas = responseObject;
    } FailureHandle:^(NSError *error) {
        
    }];
}

- (void) leftAction:(UIButton *)barItem
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (lz_UserCenterTopPic *) headerView
{
    if (!_headerView) {
        _headerView = [[lz_UserCenterTopPic alloc] init];
    }
    return _headerView;
}

- (UIView *) setup_layoutBtn
{
    UIView *vc = [UIView new];
    vc.frame = CGRectMake(0, 0, MainScreenSize.width, 100);
    vc.userInteractionEnabled = YES;
    vc.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.backgroundColor = [AppAppearance sharedAppearance].mainColor;
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitle:@"退出登录" forState:UIControlStateNormal];
    btn.frame = CGRectMake(15, 60, MainScreenSize.width - 30, 40);
    [btn addTarget:self action:@selector(layout:) forControlEvents:UIControlEventTouchUpInside];
    [vc addSubview:btn];
    
    return vc;
}

//退出登录
- (void) layout:(UIButton *)btn
{
    if (![AppDataManager defaultManager].hasLogin) {
        [self HudShowWithStatus:@"您还未登录" Delay:1.5];
        return;
    }
    
    VS_AlertVC_Logout *vc = [[VS_AlertVC_Logout alloc] init];
    vc.block = ^(UIButton *btn){
        
        [self showAlertWithAlertTitle:@"提示" alertContent:@"确定要退出吗" rightActionTitle:@"确定" rightAction:^{
            
            //登录状态更改
            [[AppDataManager defaultManager] logout];
            
            [self HudShowWithStatus:@"退出登录成功" Delay:1.5];
            [self showBackItemAction:nil];
            
        } cancelAction:^{
            
        }];
    };
    [vc show];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.cellTitles.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.text = self.cellTitles[indexPath.row];
    cell.imageView.image = [UIImage imageNamed:self.cellImages[indexPath.row]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.row) {
        case 0:
        {
            lz_VideoListTableViewController *vc = [[lz_VideoListTableViewController alloc] init];
            vc.MyController_Type = MyController_CollectionList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 1:
        {
            lz_VideoListTableViewController *vc = [[lz_VideoListTableViewController alloc] init];
            vc.MyController_Type = MyController_WorkList;
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 2:
        {
            lz_MyWaterMarkViewController *vc = [[lz_MyWaterMarkViewController alloc] init];
            vc.view.frame = CGRectMake(0, 0, MainScreenSize.width, MainScreenSize.height - 0);
            vc.type_Index = 0;
            
            UIView *view = [UIView new];
            view.frame = CGRectMake(0, 0, MainScreenSize.width, HeaderViewHeight);
            
            UIImageView *imageview = [[UIImageView alloc] initWithImage:[AppAppearance sharedAppearance].defaultImage];
            imageview.frame = CGRectMake(0, 0, view.width, view.height);
            [view addSubview:imageview];
                
            vc.headerView = view;
            [vc showPicOrText:0];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 3:
        {
            lz_MyPrivilegeViewController *vc = [[lz_MyPrivilegeViewController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case 4:
        {
            
        }
            break;
        case 5:
        {
            
        }
            break;
        case 6:
        {
            
        }
            break;
        case 7:
        {
            
        }
        break;
        default:
            break;
    }
}

- (BOOL) shouldShowGetMore
{
    return NO;
}

- (BOOL) shouldShowRefresh
{
    return NO;
}


@end
