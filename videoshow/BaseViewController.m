//
//  BaseViewController.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"
#import "LogInViewController.h"

@interface BaseViewController ()

@property (nonatomic, strong) UIView *badNetworkView;

@end

@implementation BaseViewController

- (instancetype) init
{
    if ([super init]) {
        if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
            self.edgesForExtendedLayout = UIRectEdgeAll;
        }
        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self HudHide];
}

- (void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) isOpenPopGestureRecognizer;
{
    return YES;
}

- (void) HudShowWithStatus:(NSString*)status;
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showWithStatus:status];
    
    [SVProgressHUD dismissWithDelay:1.5];
}
- (void) HudHide;
{
    [SVProgressHUD dismiss];
}

- (void) HudShowWithStatus:(NSString *)status Delay:(CGFloat)delay;
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showWithStatus:status];
    
    [SVProgressHUD dismissWithDelay:delay];
}


- (void) HudShowProgress:(CGFloat)progress status:(NSString *)status;
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showProgress:progress status:status];
}

- (void) HudShowWithStatus:(NSString *)status WithMaskType:(SVProgressHUDMaskType)type Delay:(CGFloat)delay;
{
    [SVProgressHUD setDefaultMaskType:type];
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    [SVProgressHUD showWithStatus:status];
    
    [SVProgressHUD dismissWithDelay:delay];
}

- (UIView *) badNetworkView
{
    if (!_badNetworkView) {
        _badNetworkView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 120)];
        _badNetworkView.center = CGPointMake(self.view.center.x, self.view.height/3);
        _badNetworkView.hidden = YES;
        [self.view addSubview:_badNetworkView];
        
        UIButton *imageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        imageBtn.tag = 10;
        imageBtn.frame = CGRectMake(0, 0, self.badNetworkView.width, self.badNetworkView.height-20);
        imageBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageBtn.adjustsImageWhenHighlighted = NO;
        
        [self.badNetworkView addSubview:imageBtn];
        
        UIButton *contentBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        contentBtn.tag = 11;
        contentBtn.frame = CGRectMake(0, imageBtn.bottom, self.badNetworkView.width, 20);
        contentBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [contentBtn setTitleColor:[AppAppearance sharedAppearance].alertBackgroundColor forState:UIControlStateNormal];
        
        [self.badNetworkView addSubview:contentBtn];
    }
    return _badNetworkView;
}

//展示背景图
- (void) ShowWhenBadNetworkWithImage:(UIImage *)image content:(NSString *)content;
{
    self.badNetworkView.hidden = NO;
    
    UIButton *imageBtn = [self.badNetworkView viewWithTag:10];
    [imageBtn setImage:image forState:UIControlStateNormal];
    
    UIButton *contentBtn = [self.badNetworkView viewWithTag:11];
    [contentBtn setTitle:content forState:UIControlStateNormal];
}
//隐藏背景图
- (void) HideBadNetworkBackgroundView;
{
    self.badNetworkView.hidden = YES;
}

- (void) showLoginViewControllerWithCurrentViewController:(id)rootViewController;
{
    LogInViewController *vc = [[LogInViewController alloc] init];
    [UIView animateWithDuration:.68 animations:^{
        [[UIApplication sharedApplication].keyWindow addSubview:vc.view];
    } completion:^(BOOL finished) {
        
    }];
    [rootViewController addChildViewController:vc];
}

- (void) popToRootViewControllerWithAnimated:(BOOL)animated;
{
    [self.navigationController popToRootViewControllerAnimated:animated];
}

//快速拉出系统alert
- (void) showAlertWithAlertTitle:(NSString *)alertTitle
                    alertContent:(NSString *)alertContent
                rightActionTitle:(NSString *)rightActionTitle
                     rightAction:(void (^)(void))righthandler
                    cancelAction:(void (^)(void))cancelhandler;
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:alertTitle message:alertContent preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *push = [UIAlertAction actionWithTitle:rightActionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        righthandler();
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        cancelhandler();
    }];
    [alert addAction:push];
    [alert addAction:cancel];
    
    [self.navigationController presentViewController:alert animated:YES completion:^{
        cancelhandler();
    }];
}

+(UIButton*)buttonWithImage:(UIImage*)image title:(NSString*)title target:(id)target action:(SEL)action {
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (title) {
        CGFloat hw = image.size.width/2;
        CGFloat hh = image.size.height/2;
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(hh, hw, hh, hw)];
        [btn setBackgroundImage:image forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:16];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    } else {
        [btn setImage:image forState:UIControlStateNormal];
    }
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    btn.contentEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    [btn sizeToFit];
    return btn;
}

-(void)addItemForLeft:(BOOL)left withItem:(UIBarButtonItem*)item spaceWidth:(CGFloat)width {
    UIBarButtonItem *space = [[UIBarButtonItem alloc]
                              initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                              target:nil action:nil];
    
    if (IOS7OrPlus) width -= 10;
    space.width = width;
    
    if (left) {
        self.navigationItem.leftBarButtonItems = @[space,item];
    } else {
        self.navigationItem.rightBarButtonItems = @[space,item];
    }
}

//创建多个item时使用
- (void) addItemForLeft:(BOOL)left withItems:(NSArray *)barButtonItems spaceWidth:(CGFloat)width
{
    __block CGFloat width_1 = width;
    __block NSMutableArray *result_items = [NSMutableArray arrayWithArray:barButtonItems];
    [barButtonItems enumerateObjectsUsingBlock:^(UIBarButtonItem * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc]
                                  initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                  target:nil action:nil];
        
        if (IOS7OrPlus) { width_1 -= 10;}
        space.width = width_1;
        
        [result_items addObject:space];
        [result_items addObject:obj];
    }];
    
    
    if (left) {
        self.navigationItem.leftBarButtonItems = barButtonItems;
    } else {
        self.navigationItem.rightBarButtonItems = barButtonItems;
    }
    
}

-(void)showBackItem;
{
    UIButton *btn = [self.class buttonWithImage:[UIImage imageNamed:@"item_back"] title:nil target:self action:@selector(showBackItemAction:)];
    UIBarButtonItem *item= [[UIBarButtonItem alloc]initWithCustomView:btn];
    [self addItemForLeft:YES withItem:item spaceWidth:10];
}
-(void)showBackItemAction:(UIButton *)button;
{
//    NSLog(@"需要重写%s",__FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showCloseItem;
{
    UIButton *btn_1 = [self.class buttonWithImage:[UIImage imageNamed:@"item_back"] title:nil target:self action:@selector(showBackItemAction:)];
    UIBarButtonItem *item_1 = [[UIBarButtonItem alloc]initWithCustomView:btn_1];
    
    UIButton* btn_2 = [self.class buttonWithImage:nil title:@"关闭" target:self action:@selector(showCloseItemAction:)];
    [btn_2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem* item_2 = [[UIBarButtonItem alloc] initWithCustomView:btn_2];
    
    [self addItemForLeft:YES withItems:@[item_1,item_2] spaceWidth:13];
}
- (void) showCloseItemAction:(UIButton *)button;
{
    //    NSLog(@"需要重写%s",__FUNCTION__);
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) showNextItem;
{
    UIButton* btn = [self.class buttonWithImage:nil title:@"下一步" target:self action:@selector(showNextItemAction:)];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self addItemForLeft:NO withItem:item spaceWidth:3];
}
- (void) showNextItemAction:(UIButton *)button;
{
    NSLog(@"需要重写%s",__FUNCTION__);
}

- (void) showDeleteItem;
{
    UIButton *btn = [self.class buttonWithImage:[UIImage imageNamed:@"lajixiang_03"] title:nil target:self action:@selector(showDeleteItemAction:)];
    UIBarButtonItem *item= [[UIBarButtonItem alloc]initWithCustomView:btn];
    [self addItemForLeft:NO withItem:item spaceWidth:10];
}
- (void) showDeleteItemAction:(UIButton *)button;
{
    NSLog(@"需要重写%s",__FUNCTION__);
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
