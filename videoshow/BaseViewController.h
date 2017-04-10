//
//  BaseViewController.h
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

- (BOOL) isOpenPopGestureRecognizer;

- (void) HudShowWithStatus:(NSString*)status;//默认1.5s
- (void) HudShowProgress:(CGFloat)progress status:(NSString *)status;
- (void) HudShowWithStatus:(NSString *)status Delay:(CGFloat)delay;
- (void) HudShowWithStatus:(NSString *)status WithMaskType:(SVProgressHUDMaskType)type Delay:(CGFloat)delay;
- (void) HudHide;

//唤起背景底图
- (void) ShowWhenBadNetworkWithImage:(UIImage *)image content:(NSString *)content;
- (void) HideBadNetworkBackgroundView;

//唤起登陆页
- (void) showLoginViewControllerWithCurrentViewController:(id)rootViewController;

//pop回root
- (void) popToRootViewControllerWithAnimated:(BOOL)animated;

//快速拉出系统alert
- (void) showAlertWithAlertTitle:(NSString *)alertTitle
                    alertContent:(NSString *)alertContent
                rightActionTitle:(NSString *)rightActionTitle
                     rightAction:(void (^)(void))rightAction
                     cancelAction:(void (^)(void))cancelAction;

- (void) showBackItem;
- (void) showBackItemAction:(UIButton *)button;

//webview专用
- (void) showCloseItem;
- (void) showCloseItemAction:(UIButton *)button;

- (void) showNextItem;
- (void) showNextItemAction:(UIButton *)button;

- (void) showDeleteItem;
- (void) showDeleteItemAction:(UIButton *)button;

@end
