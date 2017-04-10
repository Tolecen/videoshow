//
//  WXApiManager.m
//  videoshow
//
//  Created by gutou on 2017/3/10.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "WXApiManager.h"

@implementation WXApiManager

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    static WXApiManager *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WXApiManager alloc] init];
    });
    return instance;
}

- (void)onResp:(BaseResp *)resp
{
    if ([resp isKindOfClass:[SendAuthResp class]]) {
        if (_delegate
            && [_delegate respondsToSelector:@selector(managerDidRecvAuthResponse:)]) {
            SendAuthResp *authResp = (SendAuthResp *)resp;
            [_delegate managerDidRecvAuthResponse:authResp];
        }
    }
}

+ (BOOL) sendAuthRequestScope:(NSString *)scope
                       State:(NSString *)state
                      OpenID:(NSString *)openID
            InViewController:(UIViewController *)viewController {
    SendAuthReq* req = [[SendAuthReq alloc] init];
    req.scope = scope; // @"post_timeline,sns"
    req.state = state;
    req.openID = openID;
    
    return [self sendAuthReq:req
               viewController:viewController
                     delegate:[WXApiManager sharedManager]];
}

+ (void) registerWX_App
{
    BOOL result = [WXApi registerApp:WX_AppKey];
    if (result) {
        NSLog(@"注册wx_app成功");
    }else {
        NSLog(@"注册wx_app失败");
    }
    //向微信注册支持的文件类型
    UInt64 typeFlag = MMAPP_SUPPORT_TEXT | MMAPP_SUPPORT_PICTURE | MMAPP_SUPPORT_LOCATION | MMAPP_SUPPORT_VIDEO |MMAPP_SUPPORT_AUDIO | MMAPP_SUPPORT_WEBPAGE | MMAPP_SUPPORT_DOC | MMAPP_SUPPORT_DOCX | MMAPP_SUPPORT_PPT | MMAPP_SUPPORT_PPTX | MMAPP_SUPPORT_XLS | MMAPP_SUPPORT_XLSX | MMAPP_SUPPORT_PDF;
    
    [WXApi registerAppSupportContentFlag:typeFlag];
}


#pragma mark - 封装一步wxapi -
+ (BOOL) isWXAppInstalled;
{
    return [WXApi isWXAppInstalled];
}

+ (BOOL) handleOpenURL:(NSURL *)url delegate:(id<WXApiDelegate>) delegate;
{
    return [WXApi handleOpenURL:url delegate:delegate];
}

+ (BOOL) sendRequest:(BaseReq*)req;
{
    return [WXApi sendReq:req];
}

+ (BOOL) sendResponse:(BaseResp*)resp;
{
    return [WXApi sendResp:resp];
}

+ (BOOL) sendAuthReq:(SendAuthReq*)req viewController:(UIViewController*)viewController delegate:(id<WXApiDelegate>)delegate;
{
    return [WXApi sendAuthReq:req viewController:viewController delegate:delegate];
}



@end
