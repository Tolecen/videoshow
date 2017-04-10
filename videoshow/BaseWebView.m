//
//  BaseWebView.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseWebView.h"


@interface BaseWebView () <WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property(strong, readwrite, nonatomic)UIWebView* webView;
@property (nonatomic, assign) BOOL isBack;
@property (nonatomic, strong) UIProgressView *progressView;//进度条

@end

@implementation BaseWebView

- (WKWebView *) wkWebView
{
    if (!_wkWebView) {
        
        WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
        configuration.preferences = [[WKPreferences alloc] init];
        configuration.preferences.javaScriptEnabled = true;
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = false;
        
        configuration.userContentController = [[WKUserContentController alloc] init];
        
        _wkWebView = [[[self wkWebViewClass] alloc] initWithFrame:self.view.bounds configuration:configuration];
        _wkWebView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _wkWebView.navigationDelegate = self;
        _wkWebView.UIDelegate = self;
        [_wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_wkWebView addSubview:self.progressView];
    }
    return _wkWebView;
}

- (UIProgressView *) progressView
{
    if (!_progressView) {
        
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _progressView.frame = CGRectMake(0, 0, MainScreenSize.width, 12.5);
        _progressView.trackTintColor = [UIColor clearColor];
        _progressView.progress = 0;
        _progressView.progressTintColor = [UIColor darkGrayColor];
    }
    return _progressView;
}

- (UIWebView *) webView
{
    if (!_webView) {
        _webView = [[[self webViewClass] alloc] initWithFrame:self.view.bounds];
        _webView.delegate = self;
        _webView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scalesPageToFit = YES;
        _webView.dataDetectorTypes = UIDataDetectorTypeNone;
        [_webView addSubview:self.progressView];
    }
    return _webView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
}

- (void) showBackItemAction:(UIButton *)button
{
    [self backAction];
}

- (void) viewDidLoad
{
    [super viewDidLoad];
    [self showBackItem];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        
        [self.view addSubview:self.wkWebView];
        [self.wkWebView loadRequest:[NSURLRequest requestWithURL:self.default_Url]];
    }else {
        
        [self.view addSubview:self.webView];
        [self.webView loadRequest:[NSURLRequest requestWithURL:self.default_Url]];
    }
}

- (Class) webViewClass
{
    return [UIWebView class];
}
- (Class) wkWebViewClass
{
    return [WKWebView class];
}

#pragma mark - 动作 - 后退和退栈 -
- (void) backAction
{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        //如果可以后退
        if ([self.wkWebView canGoBack]) {
            
            [self showCloseItem];
            
            //执行后退
            [self.wkWebView goBack];
        }else {
            //如果不可以后退
            //如果栈中控制器大于1个
            if (self.navigationController.viewControllers.count > 1) {
                //返回时退栈
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                //如果控制器没有大于1 就是模态出的web,那么就dismiss
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
    }else {
        //如果系统低于8.0 执行UIWebview的方法
        if ([self.webView canGoBack]) {
            [self.webView goBack];
        }else {
            if (self.navigationController.viewControllers.count > 1) {
                [self.navigationController popViewControllerAnimated:YES];
            }else {
                [self.navigationController dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
        }
    }
}
- (void) closeAction
{
    if (self.navigationController.viewControllers.count > 1) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }else {
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
}

// 在收到响应后，决定是否跳转
- (void) webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    //    NSLog(@"%s",__FUNCTION__);
    decisionHandler(WKNavigationResponsePolicyAllow);
}

// 对于HTTPS的都会触发此代理，如果不要求验证，传默认就行
// 如果需要证书验证，与使用AFN进行HTTPS证书验证是一样的
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *__nullable credential))completionHandler;
{
    //    NSLog(@"%s", __FUNCTION__);
    completionHandler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
}

#pragma mark - WKWebviewUIDelegate -
//与JS原生的alert、confirm、prompt交互，将弹出来的实际上是我们原生的窗口，而不是JS的。在得到数据后，由原生传回到JS：

//打开新窗口委托
- (WKWebView *) webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    //    NSLog(@"%s",__FUNCTION__);
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

// JS端调用confirm函数时，会触发此方法
// 通过message可以拿到JS端所传的数据
// 在iOS端显示原生alert得到YES/NO后
// 通过completionHandler回调给JS端
- (void) webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    //    NSLog(@"%s",__FUNCTION__);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

// 在JS端调用alert函数时，会触发此代理方法。
// JS端调用alert时所传的数据可以通过message拿到
// 在原生得到结果后，需要回调JS，是通过completionHandler回调
- (void) webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
    //    NSLog(@"%s",__FUNCTION__);
}

// JS端调用prompt函数时，会触发此方法
// 要求输入一段文本
// 在原生输入得到文本内容后，通过completionHandler回调给JS
- (void) webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    //    NSLog(@"%s",__FUNCTION__);
    //    NSLog(@"prompt = %@, defaultText = %@",prompt,defaultText);
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.textColor = [UIColor blackColor];
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(defaultText);
    }]];
    [self presentViewController:alert animated:YES completion:^{
        
    }];
}

// 从web界面中接收到一个脚本时调用
- (void) userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    NSLog(@"%s",__FUNCTION__);
}

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        
        if (self.wkWebView != nil) {
            
            [self.progressView setProgress:[[change objectForKey:NSKeyValueChangeNewKey] floatValue] animated:YES];
            
            if ([[change objectForKey:NSKeyValueChangeNewKey] floatValue] >= 1) {
                
                [UIView animateWithDuration:.46 animations:^{
                    
                    self.progressView.hidden = YES;
                }];
                
            }else {
                
                self.progressView.hidden = NO;
            }
        }
    }
}

- (void) dealloc
{
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress" context:nil];
}


@end
