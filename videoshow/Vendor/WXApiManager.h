//
//  WXApiManager.h
//  videoshow
//
//  Created by gutou on 2017/3/10.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"

@protocol WXApiManagerDelegate <NSObject>

@required

//唤起第三方微信平台后返回本app时，微信方返回的消息内容
- (void) managerDidRecvAuthResponse:(SendAuthResp *)response;

@end


@interface WXApiManager : NSObject<WXApiDelegate>

@property (nonatomic, assign) id<WXApiManagerDelegate> delegate;

+ (instancetype) sharedManager;

+ (BOOL) sendAuthRequestScope:(NSString *)scope
                        State:(NSString *)state
                       OpenID:(NSString *)openID
             InViewController:(UIViewController *)viewController;


+ (void) registerWX_App;

+ (BOOL) isWXAppInstalled;

/*! @brief 处理微信通过URL启动App时传递的数据
 *
 * 需要在 application:openURL:sourceApplication:annotation:或者application:handleOpenURL中调用。
 * @param url 微信启动第三方应用时传递过来的URL
 * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL) handleOpenURL:(NSURL *) url delegate:(id<WXApiDelegate>) delegate;


/*! @brief 发送请求到微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持以下类型
 * SendAuthReq、SendMessageToWXReq、PayReq等。
 * @param req 具体的发送请求，在调用函数后，请自己释放。
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL) sendRequest:(BaseReq*)req;


/*! @brief 收到微信onReq的请求，发送对应的应答给微信，并切换到微信界面
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序收到微信onReq的请求，异步处理该请求，完成后必须调用该函数。可能发送的相应有
 * GetMessageFromWXResp、ShowMessageFromWXResp等。
 * @param resp 具体的应答内容，调用函数后，请自己释放
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL) sendResponse:(BaseResp*)resp;


/*! @brief 发送Auth请求到微信，支持用户没安装微信，等待微信返回onResp
 *
 * 函数调用后，会切换到微信的界面。第三方应用程序等待微信返回onResp。微信在异步处理完成后一定会调用onResp。支持SendAuthReq类型。
 * @param req 具体的发送请求，在调用函数后，请自己释放。
 * @param viewController 当前界面对象。
 * @param delegate  WXApiDelegate对象，用来接收微信触发的消息。
 * @return 成功返回YES，失败返回NO。
 */
+ (BOOL) sendAuthReq:(SendAuthReq*)req viewController:(UIViewController*)viewController delegate:(id<WXApiDelegate>)delegate;

@end
