//
//  BaseTableViewController.h
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface BaseTableViewController : BaseViewController<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, readonly) UITableView *tableView;
- (UITableViewStyle)tableViewStyle;
//default is UITableView Class
-(Class)tableViewClass;

//页面刷新
-(void)reloadData;

/**
 *  子类完成请求后需要调用finishRequest方法来让此类进行剩余操作
 */
-(void)finishRequest;


#pragma mark - 以下方法可以被子类重写


/**
 *  如果不想要下拉刷新，子类需要重写这个方法并返回NO
 *
 *  @return 默认为YES
 */
-(BOOL)shouldShowRefresh;


/**
 *  如果不想要上拉加载更多，子类需要重写这个方法并返回NO
 *
 *  @return 默认为YES
 */
-(BOOL)shouldShowGetMore;


/**
 *  子类需要完成重写这个方法，这个方法默认调用finishRequest方法，子类在其请求完成回调后，需要手动调用finishRequest
 */
-(void)requestRefresh;


/**
 *  子类需要完成重写这个方法，这个方法默认调用finishRequest方法，子类在其请求完成回调后，需要手动调用finishRequest
 */
-(void)requestGetMore;


@end
