//
//  lz_videoListPageViewController.m
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_videoListPageViewController.h"
#import "lz_VideoTemplateListVC.h"
#import "lz_VideoTemplateModel.h"



@interface lz_videoListPageViewController ()<UIPageViewControllerDelegate,UIPageViewControllerDataSource>

@property (nonatomic, strong) NSMutableArray *pageViewControllers;//存储page容器中装载的vc s
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

@property (nonatomic, strong) UIPageViewController *pageViewController;

@end

@implementation lz_videoListPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    self.gestureRecognizers;
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
//    [self.view addGestureRecognizer:pan];
    
    self.pageViewController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:@{UIPageViewControllerOptionInterPageSpacingKey:@0}];
    self.pageViewController.view.frame = self.view.frame;
    self.pageViewController.delegate = self;
    self.pageViewController.dataSource = self;
    [self.view addSubview:self.pageViewController.view];
    [self addChildViewController:self.pageViewController];    
}

- (void) setDatas:(NSArray *)datas
{
    _datas = datas;
    
    self.pageViewControllers = [NSMutableArray array];
    
    [datas enumerateObjectsUsingBlock:^(NSArray * obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
        lz_VideoTemplateListVC *listCollectionVC = [[lz_VideoTemplateListVC alloc] init];
        listCollectionVC.view.frame = CGRectMake(0, 0, MainScreenSize.width, MainScreenSize.height);
        listCollectionVC.view.tag = 400 + idx;
        
        [self.pageViewControllers addObject:listCollectionVC];
        
        listCollectionVC.datas = obj;
        
        WeakTypeof(weakSelf)
        listCollectionVC.didSelectBlock = ^(NSDictionary *dict) {
            
            weakSelf.didSelectBlock(dict);
        };
    }];
    
    [self.pageViewController setViewControllers:@[self.pageViewControllers.firstObject] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}

- (UICollectionViewFlowLayout *) layout
{
    if (!_layout) {
        _layout = [UICollectionViewFlowLayout new];
        _layout.minimumLineSpacing = 3;
        _layout.minimumInteritemSpacing = 3;
        _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _layout.itemSize = CGSizeMake((MainScreenSize.width-6)/2, 202);
    }
    return _layout;
}

- (void) setCurrentViewController:(NSUInteger)index;
{
    [self.pageViewController setViewControllers:@[[self.pageViewControllers objectAtIndex:index]] direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:NULL];
}


#pragma mark - pageviewcontroller的代理方法 -
//即将滑动的时候
- (void)pageViewController:(UIPageViewController *)pageViewController willTransitionToViewControllers:(NSArray<UIViewController *> *)pendingViewControllers;
{
    NSUInteger index = [self indexOfViewController:(lz_VideoTemplateListVC *)pendingViewControllers.lastObject];
//    NSLog(@"willTransition_index = %ld",index);
    
    [self setCategoryBtnSelectWithIndex:index];
}

//滑动结束
- (void)pageViewController:(UIPageViewController *)pageViewController didFinishAnimating:(BOOL)finished previousViewControllers:(NSArray<UIViewController *> *)previousViewControllers transitionCompleted:(BOOL)completed;
{
    //转换未完成
    if (completed == NO) {
        NSUInteger index = [self indexOfViewController:(lz_VideoTemplateListVC *)previousViewControllers.lastObject];
        
//        NSLog(@"didFinishAnimating_index = %ld",index);
        [self setCategoryBtnSelectWithIndex:index];
    }
}


//获取前一个或当前vc
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController;
{
    NSUInteger index = [self indexOfViewController:(lz_VideoTemplateListVC *)viewController];
    
    if ((index == 0) || (index == NSNotFound)) {
        return nil;
    }
    index--;
    
    // 返回的ViewController，将被添加到相应的UIPageViewController对象上。
    // UIPageViewController对象会根据UIPageViewControllerDataSource协议方法,自动来维护次序
    // 不用我们去操心每个ViewController的顺序问题
    return [self viewControllerAtIndex:index];
}

//获取到后一个当前vc
- (nullable UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController;
{
    NSUInteger index = [self indexOfViewController:(lz_VideoTemplateListVC *)viewController];
    
    if (index == NSNotFound) {
        return nil;
    }
    index++;
    if (index == [self.pageViewControllers count]) {
        return nil;
    }
    
    return [self viewControllerAtIndex:index];
}

//滑动设置分类btn的选中状态
- (void) setCategoryBtnSelectWithIndex:(NSInteger)index
{
//    NSLog(@"获取后一个或当前vc index = %ld",index);
    if (self.pageScrollBlock) {
        self.pageScrollBlock(index);
    }
}

- (lz_VideoTemplateListVC *)viewControllerAtIndex:(NSUInteger)index {
    if (([self.pageViewControllers count] == 0) || (index >= [self.pageViewControllers count])) {
        return nil;
    }
    lz_VideoTemplateListVC *contentVC = [self.pageViewControllers objectAtIndex:index];

    return contentVC;
}

//获取下标
- (NSUInteger)indexOfViewController:(lz_VideoTemplateListVC *)viewController {
    return [self.pageViewControllers indexOfObject:viewController];
}

@end
