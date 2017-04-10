//
//  BaseTableViewController.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseTableViewController.h"

@interface BaseTableViewController ()

@end

@implementation BaseTableViewController

- (instancetype) init
{
    if ([super init]) {
        
    }
    return self;
}

-(Class)tableViewClass
{
    return [UITableView class];
}

- (UITableViewStyle)tableViewStyle
{
    return UITableViewStylePlain;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Class class = [self tableViewClass];
    _tableView = [[class alloc] initWithFrame:self.view.bounds style:[self tableViewStyle]];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    
    if([_tableView respondsToSelector:@selector(setSeparatorInset:)])
    {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    WeakTypeof(WeakSelf)
    if ([self shouldShowRefresh]) {
        
        // 马上进入刷新状态
        [self beginRefreshing];
        
        // 设置回调
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            
            [WeakSelf requestRefresh];
        }];
    }
    if ([self shouldShowGetMore]) {
        
        // 设置回调（一旦进入刷新状态就会调用这个refreshingBlock）
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            
            [WeakSelf requestGetMore];
        }];
    }
}


#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    NSLog(@"%s 子类需要重写",__FUNCTION__);
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    NSLog(@"%s 子类需要重写",__FUNCTION__);
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)reloadData;
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

//立即进入刷新状态
- (void) beginRefreshing;
{
    [self.tableView.mj_header beginRefreshing];
}

-(void)finishRequest
{
    [self.tableView.mj_header endRefreshing];
    [self.tableView.mj_footer endRefreshing];
}

-(BOOL)shouldShowGetMore
{
    return NO;
}

-(BOOL)shouldShowRefresh
{
    return YES;
}

-(void)requestRefresh
{
    NSLog(@"%s 需要重写",__FUNCTION__);
}

-(void)requestGetMore
{
    NSLog(@"%s 需要重写",__FUNCTION__);
}

- (BOOL) shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation) preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


@end
