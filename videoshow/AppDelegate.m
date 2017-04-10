//
//  AppDelegate.m
//  videoshow
//
//  Created by mapboo on 27/02/2017.
//  Copyright © 2017 mapboo. All rights reserved.
//

#import "AppDelegate.h"

#import "BaseTabBarController.h"
#import "BaseNavigationController.h"

#import "HomeViewController.h"
#import "AdViewController.h"
#import "LogInViewController.h"
#import "BaseWebView.h"

#import <UMSocialCore/UMSocialCore.h>
#import "UMessage.h"
#import "WXApiManager.h"
#import "UMMobClick/MobClick.h"


@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    /**
//     *  进来先让启动页沉睡 2 秒钟
//     */
//    [NSThread sleepForTimeInterval:2.0];
    
    HomeViewController *homeVC = [[HomeViewController alloc] init];
    
    BaseNavigationController *navi = [[BaseNavigationController alloc] initWithRootViewController:homeVC];
    
    BaseTabBarController *tabbarController = [[BaseTabBarController alloc] init];
    [tabbarController setViewControllers:@[navi]];
    tabbarController.tabBar.hidden = YES;
    
    self.window.rootViewController = tabbarController;
    [self.window makeKeyAndVisible];
    
    [[AppDataManager defaultManager] setPublicData:@"publicData"];//激活公共属性字典
    
    [self setupWXApi];
    
    if ([AppDataManager defaultManager].adDic.allValues.count) {
        [self setupAdViewController];
    }else {
        [AppDataManager defaultManager].hasLogin == YES?nil:[self setupLoginViewController];
    }
    
    //设置友盟sdk
    [self setupUMengSDK];
    //设置友盟推送
    [UMessage startWithAppkey:UMSocial_AppKey launchOptions:launchOptions];
    [self configUMessagePlatforms];
    
    return YES;
}



//设置广告页
- (void) setupAdViewController
{
    AdViewController * adviewcontroller = [[AdViewController alloc] init];
    [self.window addSubview:adviewcontroller.adView];
    
    [UIApplication sharedApplication].statusBarHidden = YES;
    
    WeakTypeof(weakSelf)
    //此方法不可取消
    [adviewcontroller.adView startplayAdvertisingView:^(AdView * AdView) {
        
        NSLog(@"消失后允许做的动作");
        
        [AppDataManager defaultManager].hasLogin == YES?nil:[weakSelf setupLoginViewController];
        [UIApplication sharedApplication].statusBarHidden = NO;
    }];
    
    adviewcontroller.adView.leavBlock = ^(void) {
      
        NSLog(@"点击了跳过");
        [AppDataManager defaultManager].hasLogin == YES?nil:[weakSelf setupLoginViewController];
        [UIApplication sharedApplication].statusBarHidden = NO;
    };
    
    adviewcontroller.adView.detailBlock = ^(AdView *advertisingview) {
      
//        NSLog(@"跳转广告页详情,做登陆处理");
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        [advertisingview removeFromSuperview];

        NSURL *url = [NSURL URLWithString:[AppDataManager defaultManager].adDic[@"link"]];
        
        if (url) {
            BaseWebView *vc = [[BaseWebView alloc] init];
            vc.default_Url = url;
            
            if ([self.window.rootViewController isKindOfClass:[UITabBarController class]]) {
                [((UINavigationController *)((UITabBarController *)self.window.rootViewController).viewControllers.firstObject).topViewController.navigationController pushViewController:vc animated:YES];
            }
        }
    };
}

- (void) setupLoginViewController
{
    LogInViewController *vc = [[LogInViewController alloc] init];
    [[UIApplication sharedApplication].keyWindow addSubview:vc.view];
    [self.window.rootViewController addChildViewController:vc];
}

- (void) setupWXApi
{
    [WXApiManager registerWX_App];
}

//设置友盟相关
- (void) setupUMengSDK
{
    [[UMSocialManager defaultManager] openLog:YES];
    [[UMSocialManager defaultManager] setUmSocialAppkey:UMSocial_AppKey];
    [self configUSharePlatforms];
    [self confitUShareSettings];
    [self configUMobClickPlatforms];
}

- (void) configUMobClickPlatforms
{
    UMConfigInstance.appKey = UMSocial_AppKey;
    UMConfigInstance.channelId = @"App Store";
    [MobClick startWithConfigure:UMConfigInstance];//配置以上参数后调用此方法初始化SDK！
}

- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
}

- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:WX_AppKey appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    NSString *qq_appKey = [NSString stringWithFormat:@"%@",QQ_AppID];
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:qq_appKey appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
    
    /* 设置新浪的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];
}

- (void) configUMessagePlatforms
{
    //注册通知
    [UMessage registerForRemoteNotifications];
    //iOS10必须加下面这段代码。
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    center.delegate=self;
    UNAuthorizationOptions types10=UNAuthorizationOptionBadge|  UNAuthorizationOptionAlert|UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:types10     completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            //点击允许
            //这里可以添加一些自己的逻辑
        } else {
            //点击不允许
            //这里可以添加一些自己的逻辑
        }
    }];
    
#ifdef DEBUG
    [UMessage setLogEnabled:YES];
#else
    
#endif
}

- (BOOL) application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    BOOL result = [WXApiManager handleOpenURL:url delegate:[WXApiManager sharedManager]];
    if (!result) {
        // 其他如支付等SDK的回调
    }
    
    return result;
}

//
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        
        result = [WXApiManager handleOpenURL:url delegate:[WXApiManager sharedManager]];
    }
    return result;
}

- (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    if (deviceToken) {
        [[AppDataManager defaultManager] setDevice_token:deviceToken.description];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setUMessage_Alias_With_DeviceToken) name:appDidLoginNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeUMessage_Alias_With_DeviceToken) name:appDidLogoutNotification object:nil];
    }
}

- (void) setUMessage_Alias_With_DeviceToken
{
    //将账号和设备绑定
    [UMessage setAlias:[NSString stringWithFormat:@"msxx-%@.umeng-push.com",[AppDataManager defaultManager].identifier] type:@"VideoShow" response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        
    }];
}

- (void) removeUMessage_Alias_With_DeviceToken
{
    //将账号和设备解绑定
    [UMessage removeAlias:[NSString stringWithFormat:@"msxx-%@.umeng-push.com",[AppDataManager defaultManager].identifier] type:@"VideoShow" response:^(id  _Nonnull responseObject, NSError * _Nonnull error) {
        
    }];
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [UMessage didReceiveRemoteNotification:userInfo];
}

//iOS10新增：处理前台收到通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [UMessage setAutoAlert:NO];
        //应用处于前台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
#warning 处理当app在前台时点击推送进入app的情况
        
    }else{
        //应用处于前台时的本地推送接受
    }
    completionHandler(UNNotificationPresentationOptionSound|UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionAlert);
}

//iOS10新增：处理后台点击通知的代理方法
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        //应用处于后台时的远程推送接受
        //必须加这句代码
        [UMessage didReceiveRemoteNotification:userInfo];
        
#warning 处理当app在后台时点击推送进入app的情况
        
    }else{
        //应用处于后台时的本地推送接受
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
