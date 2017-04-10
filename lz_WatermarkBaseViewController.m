//
//  lz_WatermarkBaseViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_WatermarkBaseViewController.h"
#import "lz_MyWaterMarkViewController.h"
#import "lz_UpdateViewController.h"
#import "LZ_TableViewController.h"

#define HeaderViewHeight (MainScreenSize.height * 0.26)

@interface lz_WatermarkBaseViewController ()

@property (nonatomic, strong) NSMutableArray *btns;

@property (nonatomic, strong) lz_MyWaterMarkViewController *lz_MyWaterMarkViewController;
@property (nonatomic, strong) lz_UpdateViewController *lz_UpdateViewController;
@property (nonatomic, strong) LZ_TableViewController *LZ_TableViewController;

@property (nonatomic, strong) UIView *headerView;

@end

@implementation lz_WatermarkBaseViewController

- (lz_MyWaterMarkViewController *) lz_MyWaterMarkViewController
{
    if (!_lz_MyWaterMarkViewController) {
        _lz_MyWaterMarkViewController = [[lz_MyWaterMarkViewController alloc] init];
        _lz_MyWaterMarkViewController.view.frame = CGRectMake(0, 40, MainScreenSize.width, MainScreenSize.height - 40);
        _lz_MyWaterMarkViewController.type_Index = 0;
        _lz_MyWaterMarkViewController.headerView = self.headerView;
    }
    return _lz_MyWaterMarkViewController;
}


- (LZ_TableViewController *) LZ_TableViewController
{
    WeakTypeof(weakSelf)
    if (!_LZ_TableViewController) {
        _LZ_TableViewController = [[LZ_TableViewController alloc] init];
        _LZ_TableViewController.lz_OnlineVideoBlock = ^(NSInteger index) {
          
            lz_MyWaterMarkViewController *vc = [[lz_MyWaterMarkViewController alloc] init];
            vc.view.frame = CGRectMake(0, 00, MainScreenSize.width, MainScreenSize.height - 0);
            vc.type_Index = 0;
            vc.headerView = weakSelf.headerView;
            
            if (index == 0) {
                
                [vc showPicOrText:0];
                
            }else if (index == 1) {
                
                [vc showPicOrText:1];
                
            }else {}
            
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        _LZ_TableViewController.view.frame = CGRectMake(0, self.headerView.bottom, MainScreenSize.width, MainScreenSize.height - self.headerView.bottom);
    }
    return _LZ_TableViewController;
}

- (lz_UpdateViewController *) lz_UpdateViewController
{
    WeakTypeof(weakSelf)
    if (!_lz_UpdateViewController) {
        _lz_UpdateViewController = [[lz_UpdateViewController alloc] init];
        _lz_UpdateViewController.UpdateBlock = ^(NSInteger index) {
            
//            NSLog(@"index = %ld",index);
            
            [weakSelf btnChangeColorWithIndex:2];
            
            if (index == 0) {
                
                [weakSelf showMyWaterMarkView];
                
                [weakSelf.lz_MyWaterMarkViewController showPicOrText:0];
                
            }else if (index == 1) {
                
                [weakSelf showMyWaterMarkView];
                
                [weakSelf.lz_MyWaterMarkViewController showPicOrText:1];
                
            }else {
                
            }
        };
        _lz_UpdateViewController.view.frame = CGRectMake(0, HeaderViewHeight + 39, MainScreenSize.width, MainScreenSize.height - HeaderViewHeight - 50);
    }
    return _lz_UpdateViewController;
}

- (void) showMyWaterMarkView
{
    WeakTypeof(weakSelf)
    if (![weakSelf.view.subviews containsObject:weakSelf.lz_MyWaterMarkViewController.view]) {
        [weakSelf.view addSubview:weakSelf.lz_MyWaterMarkViewController.view];
        [weakSelf addChildViewController:weakSelf.lz_MyWaterMarkViewController];
    }
    [weakSelf.view bringSubviewToFront:weakSelf.lz_MyWaterMarkViewController.view];
    [weakSelf.LZ_TableViewController allPause];
    weakSelf.lz_MyWaterMarkViewController.view.hidden = NO;
}

- (void) btnChangeColorWithIndex:(NSInteger)index
{
    WeakTypeof(weakSelf)
    [weakSelf.btns enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == index) {
            [obj setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [obj setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
        }else {
            [obj setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
            [obj setBackgroundColor:[UIColor whiteColor]];
        }
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"水印视频";
    [self showBackItem];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.btns = [NSMutableArray array];
    
    
    NSArray *titles = @[@"在线视频",@"自主上传",@"我的水印",];
    CGFloat topBtnWidth = (MainScreenSize.width-40)/3;
    for (NSInteger i = 0; i < 3; i++) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.layer.cornerRadius = 5;
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [AppAppearance sharedAppearance].mainColor.CGColor;
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        btn.frame = CGRectMake(10 + i * (topBtnWidth + 10), 5, topBtnWidth, 30);
//        [self.view addSubview:btn];
        btn.tag = i + 10;
        [self.btns addObject:btn];
        
        if (i == 0) {
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
        }else {
            [btn setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
            [btn setBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    [self.view addSubview:self.headerView];
    
//    [self.view addSubview:self.lz_OnlineVideoViewController.view];
//    [self addChildViewController:self.lz_OnlineVideoViewController];
    [self.view addSubview:self.LZ_TableViewController.view];
    [self addChildViewController:self.LZ_TableViewController];
    
    //最上层显示在线视频
    [self.view bringSubviewToFront:self.LZ_TableViewController.view];
}

- (UIView *) headerView
{
    UIView *view = [UIView new];
    view.frame = CGRectMake(0, 0, MainScreenSize.width, HeaderViewHeight);
    
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[AppAppearance sharedAppearance].defaultImage];
    imageview.frame = CGRectMake(0, 0, view.width, view.height);
    [view addSubview:imageview];
    
    return view;
}

- (void) btnAction:(UIButton *)btn
{
    [self.btns enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (btn == obj) {
            [obj setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [obj setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
        }else {
            [obj setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
            [obj setBackgroundColor:[UIColor whiteColor]];
        }
    }];
    
    //在线视频
    if (btn.tag == 10) {
        
        [self.view bringSubviewToFront:self.LZ_TableViewController.view];
        [self.LZ_TableViewController allPlay];
        
        if ([self.view.subviews containsObject:self.lz_MyWaterMarkViewController.view]) {
            self.lz_MyWaterMarkViewController.view.hidden = YES;
        }
    }else if (btn.tag == 11) {//自主上传
        
        if (![self.view.subviews containsObject:self.lz_UpdateViewController.view]) {
            [self.view addSubview:self.lz_UpdateViewController.view];
            [self addChildViewController:self.lz_UpdateViewController];
        }
        
        [self.view bringSubviewToFront:self.lz_UpdateViewController.view];
        [self.LZ_TableViewController allPause];
        
        if ([self.view.subviews containsObject:self.lz_MyWaterMarkViewController.view]) {
            self.lz_MyWaterMarkViewController.view.hidden = YES;
        }
    }else {//我的水印
        
        if (![self.view.subviews containsObject:self.lz_MyWaterMarkViewController.view]) {
            [self.view addSubview:self.lz_MyWaterMarkViewController.view];
            [self addChildViewController:_lz_MyWaterMarkViewController];
        }
        [self.view bringSubviewToFront:self.lz_MyWaterMarkViewController.view];
        [self.LZ_TableViewController allPause];
        self.lz_MyWaterMarkViewController.view.hidden = NO;
    }
}

- (UIButton *) createBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.cornerRadius = 5;
    [btn setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn setBackgroundColor:[AppAppearance sharedAppearance].mainColor];
    [btn setBackgroundColor:[UIColor whiteColor]];
    
    return btn;
}


@end
