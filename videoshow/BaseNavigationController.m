//
//  BaseNavigationController.m
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseNavigationController.h"
#import "BaseViewController.h"

@interface BaseNavigationController ()<UIGestureRecognizerDelegate>

@end

@implementation BaseNavigationController

- (instancetype)init
{
    self = [super init];
    if (self) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    return self;
}

- (instancetype) initWithRootViewController:(UIViewController *)rootViewController
{
    if ([super initWithRootViewController:rootViewController]) {
        if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self.navigationBar setBackgroundImage:[AppTool createImageFromColor:[UIColor clearColor] withRect:CGRectZero] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
    self.navigationBar.translucent = NO;
    
    UIColor* color = [UIColor whiteColor];
    NSDictionary * dict = [NSDictionary dictionaryWithObject:color forKey:NSForegroundColorAttributeName];
    
    self.navigationBar.titleTextAttributes = dict;
    
    static  dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        //获取系统原始pop手势的view,并把手势关闭
        UIGestureRecognizer *gesture = self.interactivePopGestureRecognizer;
        gesture.enabled = NO;
        UIView *view = gesture.view;
        
        //获取手势的targets数组
        NSMutableArray *_tragets = [gesture valueForKey:@"_targets"];
        //获取它的唯一对象,我们知道它是一个叫 UIGestureRecognizerTarget 的私有类,它有一个属性叫_target
        id gestureRecognizerTarget = [_tragets firstObject];
        //获取_target: _UINavigationiIteractiveTransition ,它有一个方法是handleNavigationTransition:
        id navigationiIteractiveTransition = [gestureRecognizerTarget valueForKey:@"_target"];
        //取出方法打印
        SEL handleTransition = NSSelectorFromString(@"handleNavigationTransition:");
        //创建一个与系统一模一样的手势,我们只把它的类改成 UIPanGestureRecognizer
        UIPanGestureRecognizer *popGesture = [[UIPanGestureRecognizer alloc] initWithTarget:navigationiIteractiveTransition action:handleTransition];
        popGesture.delegate = self;
        [view addGestureRecognizer:popGesture];
    });
}

//当手势触发时
- (BOOL) gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *)gestureRecognizer;
    CGPoint translation = [pan translationInView:self.view];
    //    CGPoint location = [pan locationInView:self.view];
    /**
     *  这里有两个条件不允许手势执行:
     *
     *  1.当前控制器为根控制器
     *  2.如果正在进行push、pop动画 (私有属性)
     *  3.必须是右滑才能触发
     */
    //    NSLog(@"translationInView ======== %d",self.viewControllers.count != 1 && ![[self valueForKey:@"_isTransitioning"] boolValue] && translation.x > 0);
    
    //判断如果当前页面继承base，是否打开pop手势
    if ([self.topViewController isKindOfClass:[BaseViewController class]]) {
        return self.viewControllers.count != 1 && ![[self valueForKey:@"_isTransitioning"] boolValue] && translation.x > 0 && [((BaseViewController *)self.topViewController) isOpenPopGestureRecognizer];
    }
    
    return self.viewControllers.count != 1 && ![[self valueForKey:@"_isTransitioning"] boolValue] && translation.x > 0;
}

- (BOOL) shouldAutorotate
{
    return [self.topViewController shouldAutorotate];
}


- (UIInterfaceOrientationMask)navigationControllerSupportedInterfaceOrientations:(UINavigationController *)navigationController NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
{
    return [self.topViewController supportedInterfaceOrientations];
}


- (UIInterfaceOrientation)navigationControllerPreferredInterfaceOrientationForPresentation:(UINavigationController *)navigationController NS_AVAILABLE_IOS(7_0) __TVOS_PROHIBITED;
{
    return [self.topViewController preferredInterfaceOrientationForPresentation];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return [self.topViewController preferredStatusBarStyle];
}


@end
