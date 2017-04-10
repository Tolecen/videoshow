//
//  BaseWebView.h
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

#import "BaseViewController.h"

@interface BaseWebView : BaseViewController<UIWebViewDelegate>
{
@protected
    UIWebView* _webView;
    WKWebView *_wkWebView;
}


@property (nonatomic, strong) NSURL *default_Url;

@property(strong, readonly, nonatomic)UIWebView* webView;
-(Class)webViewClass;

@property (nonatomic, strong) WKWebView *wkWebView;
- (Class) wkWebViewClass;

@end
