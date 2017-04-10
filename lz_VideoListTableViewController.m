//
//  lz_VideoListTableViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_VideoListTableViewController.h"
#import "lz_VideoDetailViewController.h"
#import "lz_VideoTemplateBaseVC.h"

#import "lz_VideoTemplateModel.h"

#import "VedioDetailCell.h"
#import "lz_MyCollectionCell.h"

@interface lz_VideoListTableViewController ()

@property (nonatomic, assign) NSInteger page;

@property (nonatomic, strong) NSMutableArray *dataArr;

@end

@implementation lz_VideoListTableViewController

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
    self.tableView.backgroundColor = [UIColor whiteColor];
    self.tableView.tableFooterView = [UIView new];
    if (self.MyController_Type == MyController_CollectionList) {
        self.title = @"我的收藏";
    }else if (self.MyController_Type == MyController_WorkList) {
        self.title = @"我的作品";
    }else {
        
    }
    
    self.page = 1;
    
    self.dataArr = [NSMutableArray array];
    
    [self requestRefresh];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.MyController_Type == MyController_CollectionList) {
        return [lz_MyCollectionCell cellHeightWithData:nil];
    }else if (self.MyController_Type == MyController_WorkList) {
        return [VedioDetailCell cellHeightWithData:nil];
    }else {
        return 0.001;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.MyController_Type == MyController_CollectionList) {
        lz_MyCollectionCell *cell = [lz_MyCollectionCell cellWithTableView:tableView reuseIdentifier:nil indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.dataArr[indexPath.row];
        
        return cell;
    }else if (self.MyController_Type == MyController_WorkList) {
        VedioDetailCell *cell = [VedioDetailCell cellWithTableView:tableView reuseIdentifier:nil indexPath:indexPath];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        WeakTypeof(weakSelf)
        cell.VedioDetailCell_deleteDataBlock = ^(lz_VideoTemplateModel *model) {
            
            NSLog(@"删除");
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[weakSelf.dataArr indexOfObject:model] inSection:0];
            [weakSelf showAlertWithAlertTitle:@"提示" alertContent:@"确定要删除吗" rightActionTitle:@"确定" rightAction:^{
                
                [lz_VideoTemplateModel requestMyWorkDetailWithTemplate_id:model.template_id
                                                                 isDetail:NO
                                                            SuccessHandle:^(id responseObject) {
                                                                
                                                                if (responseObject) {
                                                                    [weakSelf.dataArr removeObject:model];
                                                                    [weakSelf.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
                                                                    [weakSelf HudShowWithStatus:@"删除成功" Delay:0.5];
                                                                }
                                                            } FailureHandle:^(NSError *error) {
                                                                
                                                            }];
                
            } cancelAction:^{

            }];
        };
        cell.model = self.dataArr[indexPath.row];
        
        return cell;
    }else {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    lz_VideoDetailViewController *vc = [lz_VideoDetailViewController new];
    lz_VideoTemplateModel *model = [lz_VideoTemplateModel new];
    model = self.dataArr[indexPath.row];
    vc.dict = @{@"model":model};
    
    
    if (self.MyController_Type == MyController_CollectionList) {
        
        vc.MyController_Type = MyController_UseTemplate;
        
    }else if (self.MyController_Type == MyController_WorkList) {
        
        vc.MyController_Type = MyController_ShareTemplate;
        
    }else {}
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) requestGetMore
{
    self.page ++;
    
    if (self.MyController_Type == MyController_WorkList) {//我的作品
        
        [lz_VideoTemplateModel requestMyWorkListWithPage:[NSNumber numberWithInteger:self.page]
                                                  length:@10
                                           SuccessHandle:^(id responseObject) {
            
            if (!((NSArray *)responseObject).count) {
                self.page = 1;
                
            }else {
                [self.dataArr addObjectsFromArray:responseObject];
            }
            [self reloadData];
            [self finishRequest];
        } FailureHandle:^(NSError *error) {
            [self finishRequest];
        }];
    }else if (self.MyController_Type == MyController_CollectionList){//我的收藏
        
        [lz_VideoTemplateModel requestMyCollectionListWithStyle_id:nil
                                                         is_charge:nil
                                                          is_short:nil
                                                              Page:[NSNumber numberWithInteger:self.page]
                                                            length:@10
                                                     SuccessHandle:^(id responseObject) {
                                                         
                                                         if (!((NSArray *)responseObject).count) {

                                                         }else {
                                                             [self.dataArr addObjectsFromArray:responseObject];
                                                         }
                                                         [self reloadData];
                                                         [self finishRequest];
                                                     } FailureHandle:^(NSError *error) {
                                                         [self HudShowWithStatus:@"没有更多了"];
                                                     }];
        
    }else {
        
    }
}

- (void) requestRefresh
{
    if (self.MyController_Type == MyController_WorkList) {
        [lz_VideoTemplateModel requestMyWorkListWithPage:[NSNumber numberWithInteger:self.page] length:@10 SuccessHandle:^(id responseObject) {
            
            if (!((NSArray *)responseObject).count) {
                [self showAlertWithAlertTitle:@"提示"
                                 alertContent:@"您还没有作品，快去创作一个吧。"
                             rightActionTitle:@"前往"
                                  rightAction:^{
                                      
                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                      lz_VideoTemplateBaseVC *vc = [[lz_VideoTemplateBaseVC alloc] init];
                                      vc.Template_Type = Template_Short;
                                      [self.navigationController pushViewController:vc animated:YES];
                                      
                                  } cancelAction:^{
                                      [self showBackItemAction:nil];
                                  }];
            }
            [self.dataArr setArray:responseObject];
            [self reloadData];
            [self finishRequest];
        } FailureHandle:^(NSError *error) {
            [self finishRequest];
        }];
    }else if (self.MyController_Type == MyController_CollectionList){
        
        [lz_VideoTemplateModel requestMyCollectionListWithStyle_id:nil
                                                         is_charge:nil
                                                          is_short:nil
                                                              Page:[NSNumber numberWithInteger:self.page]
                                                            length:@10
                                                     SuccessHandle:^(id responseObject) {
                                                         
                                                         if (!((NSArray *)responseObject).count) {
                                                             self.page = 1;
                                                             [self ShowWhenBadNetworkWithImage:nil content:@"暂无收藏"];
                                                         }else {
                                                             [self HideBadNetworkBackgroundView];
                                                             [self.dataArr addObjectsFromArray:responseObject];
                                                         }
                                                         
                                                         [self reloadData];
                                                         [self finishRequest];
                                                     } FailureHandle:^(NSError *error) {
                                                         [self finishRequest];
                                                     }];
        
    }else {
        
    }
}


@end
