//
//  lz_PayOnline_ViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/29.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_PayOnline_ViewController.h"

#import "lz_payTypeCell.h"

@interface lz_PayOnline_ViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) UITableView *selectTableView;

@property (nonatomic, assign) NSInteger selectIndex;

@end

@implementation lz_PayOnline_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self showBackItem];
    
    self.title = @"充值";
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    
    self.selectIndex = self.defaultIndex;
    
    self.titles = [NSArray arrayWithObjects:@"微信支付",@"支付宝支付", nil];
    self.images = [NSArray arrayWithObjects:[UIImage imageNamed:@"weixin"],[UIImage imageNamed:@"alipay"], nil];
    
    UIView *topView = [UIView new];
    topView.frame = CGRectMake(0, 0, MainScreenSize.width, 60);
    topView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:topView];
    
    UIImageView *leftImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo_small"]];
    leftImageView.frame = CGRectMake(20, 0, 100, topView.height);
    [leftImageView sizeToFit];
    leftImageView.center = CGPointMake(leftImageView.center.x, topView.height/2);
    leftImageView.layer.cornerRadius = leftImageView.width/2;
    [topView addSubview:leftImageView];
    
    UILabel *titleLab = [UILabel new];
    titleLab.frame = CGRectMake(leftImageView.right, 0, 100, 30);
    titleLab.center = CGPointMake(titleLab.center.x, leftImageView.center.y);
    titleLab.text = @"充值会员";
    [topView addSubview:titleLab];
    
    [self.view addSubview:self.selectTableView];
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    [payBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [payBtn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
    [payBtn addTarget:self action:@selector(payAction:) forControlEvents:UIControlEventTouchUpInside];
    payBtn.frame = CGRectMake(10, self.selectTableView.bottom + 70, MainScreenSize.width-20, 44);
    [self.view addSubview:payBtn];
}

- (void) payAction:(UIButton *)btn
{
    [self showPayWithIndex:self.selectIndex];
    NSLog(@"支付");
}

- (void) setDefaultIndex:(NSInteger)defaultIndex
{
    _defaultIndex = defaultIndex;
    
    [self.selectTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:defaultIndex inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
}

- (UITableView *) selectTableView
{
    if (!_selectTableView) {
        _selectTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 70, MainScreenSize.width, 44*2) style:UITableViewStylePlain];
        _selectTableView.scrollEnabled = NO;
        _selectTableView.delegate = self;
        _selectTableView.dataSource = self;
    }
    return _selectTableView;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    lz_payTypeCell *cell = [[lz_payTypeCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    
    cell.imageView.image = self.images[indexPath.row];
    cell.textLabel.text = self.titles[indexPath.row];;
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectIndex = indexPath.row;
}

- (void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
}

//唤起支付
- (void) showPayWithIndex:(NSInteger)inedx
{
    switch (inedx) {
        case 0:
        {
            
        }
        break;
        case 1:
        {
            
        }
        break;
        default:
        break;
    }
}


@end
