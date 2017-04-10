//
//  AppOpenUrlManager.m
//  videoshow
//
//  Created by gutou on 2017/3/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AppOpenUrlManager.h"
#import "WXApiManager.h"

@implementation AppOpenUrlManager

+ (instancetype)shareInstance{
    static AppOpenUrlManager *manager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[AppOpenUrlManager alloc]init];
    });
    return manager;
}

- (BOOL) isCanOpenUrlWithCallURLMode:(CallURLMode)urlMode
{
    switch (urlMode) {
        case CallURL_WeiXin_Social:
        {
            if ([WXApi isWXAppInstalled]) {
                return YES;
            }else {
                [self showAlertTitle:@"提示" andContent:@"没有安装微信客户端"];
                return NO;
            }
        }
        break;
        case CallURL_QQ_Social:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        case CallURL_Sina_Social:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        case CallURL_Baidu_Map:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        case CallURL_Google_Map:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        case CallURL_Gaode_Map:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        case CallURL_Apple_Map:
        {
//            return [WXApi isWXAppInstalled]?(YES):(NO);
        }
        break;
        default:
        break;
    }
    return NO;
}


/*
    用于弹出警告提示信息
    @param title:警告框的标题
    @param content:警告框显示的提示性内容
*/

- (void)showAlertTitle:(NSString *)title andContent:(NSString *)content{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:content
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * _Nonnull action) {
                                                             [alert dismissViewControllerAnimated:YES completion:^{
                                                                 
                                                             }];
                                                         }];
    [alert addAction:cancelAction];
    
    [[UIApplication sharedApplication].windows.lastObject.rootViewController presentViewController:alert animated:YES completion:^{
        
    }];
}

@end
