//
//  lz_VideoTemplateBaseVC.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_VideoTemplateBaseVC.h"
#import "BaseShareViewController.h"
#import "lz_VideoDetailViewController.h"
#import "XlScrollViewController.h"
#import "lz_videoListPageViewController.h"
#import "BaseWebView.h"

#import "VS_BottomImageButton.h"
#import "lz_videoCategoryScroll.h"

#import <UMSocialCore/UMSocialCore.h>

#import "lz_VideoTemplateModel.h"
#import "BannerModel.h"


typedef enum : NSUInteger {
    Price_Free,//免费
    Price_Charge,
} Price_Type;

@interface lz_VideoTemplateBaseVC ()<UIScrollViewDelegate,lz_videoDelegate,XLScrollViewDelegate2>

@property (nonatomic, strong) XlScrollViewController *adScrollView;//轮播图

@property (nonatomic, strong) VS_BottomImageButton *btn_1;
@property (nonatomic, strong) VS_BottomImageButton *btn_2;

@property (nonatomic, assign) Price_Type freeOrChargeTag;//判断是否付费  0:免费 1:付费


@property (nonatomic, strong) lz_videoCategoryScroll *categoryScrollView;//免费or付费栏目下类别
@property (nonatomic, strong) lz_videoListPageViewController *pageViewController;//底部collection左右翻页控制器

@property (nonatomic, strong) NSArray *categoryArr;//收费或付费请求到的类别数据
@property (nonatomic, strong) NSMutableArray *videoListArr;//页面下方视频模板列表数据

@property (nonatomic, strong) NSCache *pageViewControllersCache;//缓存左右翻页的控制器

@end

@implementation lz_VideoTemplateBaseVC

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (XlScrollViewController *) adScrollView
{
    if (!_adScrollView) {
        _adScrollView = [[XlScrollViewController alloc]init];
        _adScrollView.delegate = self;
        _adScrollView.view.frame = CGRectMake(0, 0, MainScreenSize.width, MainScreenSize.height * .24f);
        _adScrollView.animationDuration = 3.f;
        _adScrollView.pageNumber = 0;
        _adScrollView.view.backgroundColor  = [UIColor whiteColor];
        _adScrollView.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _adScrollView.view.contentMode      = UIViewContentModeScaleToFill;
    }
    
    return _adScrollView;
}

//轮播图的点击事件代理
- (void) XLscrollView:(XLScrollView *)scrollView contentViewTapAction:(NSInteger)pageIndex Model:(id)model
{
    NSLog(@"点击了轮播图");
    BaseWebView *webVC = [[BaseWebView alloc] init];
    webVC.default_Url = [NSURL URLWithString:((BannerModel *)model).link];
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"视频模板";
    [self showBackItem];
    
    self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.categoryArr = [NSArray array];
    
    self.freeOrChargeTag = 0;
    self.pageViewControllersCache = [[NSCache alloc] init];
    
    [self.view addSubview:self.adScrollView.view];
    
    //请求轮播图数据
    [self requestBanner];
    
    //创建 免费or付费 按钮
    [self setupButtons];
    
    [self.view addSubview:self.categoryScrollView];
    
    [self.view addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];
    [self.pageViewController didMoveToParentViewController:self];
    
    //请求 免费or付费 下类别数据
    [self requestCategoryScrollViewData];    
}

//轮播图数据
- (void) requestBanner
{
    WeakTypeof(weakSelf);
    [BannerModel requestBannerModelOfCompletionHandler:^(id responseObject) {
        
        //请求数据后调用
        [weakSelf.adScrollView updateOfInterface:responseObject];
        
    } failHandler:^(NSError *error) {
        
    }];
}

//创建 免费or付费 按钮
- (void) setupButtons
{
    self.btn_1 = [VS_BottomImageButton buttonWithType:UIButtonTypeCustom];
    self.btn_1.frame = CGRectMake(0, CGRectGetMaxY(self.adScrollView.view.frame), MainScreenSize.width/2, 41.5);
    self.btn_1.tag = 2001;
    [self.btn_1 addTarget:self action:@selector(action_1:) forControlEvents:UIControlEventTouchUpInside];
    self.btn_1.selected = YES;
    [self.btn_1 setTitle:@"免费" forState:UIControlStateNormal];
    [self.view addSubview:self.btn_1];

    
    self.btn_2 = [VS_BottomImageButton buttonWithType:UIButtonTypeCustom];
    self.btn_2.frame = CGRectMake(self.btn_1.right, self.btn_1.top, self.btn_1.width, self.btn_1.height);
    self.btn_2.tag = 2002;
    self.btn_2.selected = NO;
    [self.btn_2 addTarget:self action:@selector(action_1:) forControlEvents:UIControlEventTouchUpInside];
    [self.btn_2 setTitle:@"付费" forState:UIControlStateNormal];
    [self.view addSubview:self.btn_2];
}

//付费免费按钮取反动作
- (void) action_1:(UIButton *)btn
{
    //如果点击的是免费按钮
    if (btn.tag == 2001) {
        
        if (btn.selected == YES) {
            //无操作
        }else {
            self.btn_2.selected = !self.btn_2.selected;
            btn.selected = !btn.selected;
            
            self.freeOrChargeTag = 0;
            NSLog(@"点击了%@btn,状态是%d",btn.titleLabel.text,btn.selected);
            
            [self requestCategoryScrollViewData];
        }
    }else {
        if (btn.selected == NO) {
            
            self.btn_1.selected = !self.btn_1.selected;
            btn.selected = !btn.selected;
            
            self.freeOrChargeTag = 1;
            NSLog(@"点击了%@btn,状态是%d",btn.titleLabel.text,btn.selected);
            
            [self requestCategoryScrollViewData];
        }else{
            
        }
    }
}

- (void) lz_videoDidselect:(UIButton *)btn;
{
    NSLog(@"点击了第%ld个btn",btn.tag);
    
    [self.pageViewController setCurrentViewController:btn.tag-300];
}

- (lz_videoCategoryScroll *) categoryScrollView
{
    if (!_categoryScrollView) {
        _categoryScrollView = [[lz_videoCategoryScroll alloc] initWithFrame:CGRectMake(0, self.btn_1.bottom, MainScreenSize.width, 40)];
        _categoryScrollView.lz_videoDelegate = self;
        _categoryScrollView.tag = 299;
    }
    return _categoryScrollView;
}

//滑动page 联动category scroll
- (void) setSelectCategoryBtn:(NSInteger)index
{
    [self.categoryScrollView setSelectBtn:index];
}

//请求中部类别数据 && 创建中部类别
- (void) requestCategoryScrollViewData
{
    WeakTypeof(weakSelf)
    [self HudShowWithStatus:@"正在加载"];
    
    self.videoListArr = [NSMutableArray array];
    [lz_VideoTemplateModel requestStyleWithSuccessHandle:^(id responseObject) {
                
        /* 
             @[@"震撼",@"唯美",@"简洁",@"可爱",@"绚丽",@"复古",@"测试",@"测试2"]
         */
        
        //给分类数据
        [weakSelf.categoryScrollView setDatas:responseObject];
        
        [responseObject enumerateObjectsUsingBlock:^(lz_VideoTemplateModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
           
            //存储所有的视频列表需要请求的参数
            NSArray *temp_1 = [NSArray arrayWithObjects:   [NSNumber numberWithInteger:[obj.template_id integerValue]],
                                                           [NSNumber numberWithInteger:self.freeOrChargeTag],
                               [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:self.Template_Type]],
                                                           [NSNumber numberWithInteger:1],
                                                           [NSNumber numberWithInteger:4],nil];
            [weakSelf.videoListArr addObject:temp_1];
        }];
        
        //给左右视频列表数据
        [weakSelf.pageViewController setDatas:weakSelf.videoListArr];
        
        [self HudHide];
        
    } FailureHandle:^(NSError *error) {
        
    }];
}


- (lz_videoListPageViewController *) pageViewController
{
    if (!_pageViewController) {
        _pageViewController = [[lz_videoListPageViewController alloc] init];
        
        _pageViewController.view.frame = CGRectMake(0, CGRectGetMaxY(self.categoryScrollView.frame)+1, MainScreenSize.width, MainScreenSize.height - CGRectGetMaxY(self.categoryScrollView.frame));
        
        _pageViewController.view.tag = 4001;
        
        WeakTypeof(weakSelf)
        _pageViewController.didSelectBlock = ^(NSDictionary *dict) {
            
            NSLog(@"点击了视频列表中的某一个");
            lz_VideoDetailViewController *vc = [lz_VideoDetailViewController new];
            vc.dict = dict;
            vc.MyController_Type = MyController_UseTemplate;
            [weakSelf.navigationController pushViewController:vc animated:YES];
        };
        
        _pageViewController.pageScrollBlock = ^(NSInteger index) {
            
            NSLog(@"滑动到了某一页 index = %ld",index);
            [weakSelf setSelectCategoryBtn:index];
        };
    }
    return _pageViewController;
}

@end
