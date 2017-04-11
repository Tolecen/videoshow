//
//  BabyBaseVC.m
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyBaseVC.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"



@interface BabyBaseVC ()
@property(nonatomic, strong) AFNetworkReachabilityManager *reachabilityMannger;
@end

@implementation BabyBaseVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = BACKGROUND_COLOR;
    NSDictionary *dicts = [NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], NSForegroundColorAttributeName, kFontSize(18), NSFontAttributeName, nil];
    
    UIImage *image = ImageNamed(@"baby_icn_back");
    UIBarButtonItem *item = [[UIBarButtonItem alloc] init];
    item.title = @"返回";
    [item setTitleTextAttributes:dicts forState:UIControlStateNormal];
    [item setBackButtonBackgroundImage:[image resizableImageWithCapInsets:UIEdgeInsetsMake(0, image.size.width, 0, 0)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    self.navigationItem.backBarButtonItem = item;
    self.automaticallyAdjustsScrollViewInsets = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self startNetworkReachability];
    [self initUserInfo];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(initUserInfo) name:NOTIFICATION_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploaPinNotification:) name:NOTIFICATION_PIN_UPLOAD object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schemeToPin:) name:NOTIFICATION_SCHEME_PIN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schemeToUser:) name:NOTIFICATION_SCHEME_USER object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schemeToTag:) name:NOTIFICATION_SCHEME_TAG object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(schemeToSubject:) name:NOTIFICATION_SCHEME_SUBJECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotification:) name:NOTIFICATION_PUSH_MESSAGE object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [SVProgressHUD dismiss];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_USER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PIN_UPLOAD object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SCHEME_PIN object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SCHEME_USER object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SCHEME_TAG object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_SCHEME_SUBJECT object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIFICATION_PUSH_MESSAGE object:nil];
    [self stopNetworkReachability];
    
}
//
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//
//-(void)uploaPinNotification:(NSNotification*)notification
//{
//    DLog(@"uploaPinNotification -----");
//    NSDictionary *nameDictionary = [notification userInfo];
//    Pin *pin = [nameDictionary objectForKey:@"pin"];
//    if (pin) {
//        [self sharePinPublished:pin];
//    }
//    
//}
//
//- (void)pushPinDetail:(long)pinId
//{
//    PinDetailViewController *pinDetail = [[PinDetailViewController alloc]init];
//    pinDetail.hidesBottomBarWhenPushed=YES;
//    pinDetail.pinId = pinId;
//    [self.navigationController pushViewController:pinDetail animated:YES];
//}
//
//- (void)pushSubject:(long)subjcetId
//{
//    SubjectViewController *subjectController = [[SubjectViewController alloc] initWithSubjectId:subjcetId];
//    subjectController.buttonTintColor = UIColorFromRGB(BABYCOLOR_base_color);
//    subjectController.buttonBottomTintColor = UIColorFromRGB(BABYCOLOR_base_color);
//    subjectController.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:subjectController animated:YES];
//}
//
//-(void)schemeToPin:(NSNotification*)notification
//{
//    NSDictionary *nameDictionary = [notification userInfo];
//    NSString *pinId = [nameDictionary objectForKey:@"pinId"];
//    DLog(@"schemeToPin ----- %@", pinId);
//    [self pushPinDetail:(long)[pinId longLongValue]];
//}
//
//-(void)schemeToUser:(NSNotification*)notification
//{
//    NSDictionary *nameDictionary = [notification userInfo];
//    NSString *userId = [nameDictionary objectForKey:@"userId"];
//    DLog(@"schemeToUser ----- %@", userId);
//    
//    UserViewController *userDetail = [[UserViewController alloc]init];
//    userDetail.hidesBottomBarWhenPushed=YES;
//    userDetail.userId = (long)[userId longLongValue];
//    [self.navigationController pushViewController:userDetail animated:YES];
//}
//
//-(void)schemeToTag:(NSNotification*)notification
//{
//    NSDictionary *nameDictionary = [notification userInfo];
//    NSString *tagId = [nameDictionary objectForKey:@"tagId"];
//    DLog(@"schemeToTag ----- %@", tagId);
//    
//    TagViewController *tag = [[TagViewController alloc]init];
//    tag.tag_id = (long)[tagId longLongValue];
//    tag.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:tag animated:YES];
//}
//
//- (void)schemeToSubject:(NSNotification*)notification
//{
//    NSDictionary *nameDictionary = [notification userInfo];
//    NSString *subjectId = [nameDictionary objectForKey:@"subjectId"];
//    DLog(@"schemeToSubject ----- %@", subjectId);
//    SubjectViewController *subjectController = [[SubjectViewController alloc] initWithSubjectId:(long)[subjectId longLongValue]];
//    subjectController.buttonTintColor = UIColorFromRGB(BABYCOLOR_base_color);
//    subjectController.buttonBottomTintColor = UIColorFromRGB(BABYCOLOR_base_color);
//    subjectController.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:subjectController animated:YES];
//}
//
//- (void)pushNotification:(NSNotification*)notification
//{
//    //[MobClick event:@"openNotification"];
//    DLogV("pushNotification : %@", notification);
//    NSDictionary *nameDictionary = [notification userInfo];
//    NSDictionary *mengbaopai = [nameDictionary objectForKey:@"mengbaopai"];
//    DLogV("mengbaopai : %@", mengbaopai);
//    BabyMessage *message = [BabyMessage mj_objectWithKeyValues:mengbaopai];
//    
//    DLogV("message type : %d", message.type);
//    DLogV("message ref_id : %d", message.ref_id);
//    DLogV("message message : %@", message.message);
//    
//    switch (message.type) {
//        case MESSAGE_MAIN:
//            
//            break;
//        case MESSAGE_MESSSAGE:{
//            MeMessageViewController *messageVC = [[MeMessageViewController alloc]init];
//            messageVC.hidesBottomBarWhenPushed = YES;
//            [self.navigationController pushViewController:messageVC animated:YES];
//        }
//            
//            break;
//        case MESSAGE_TAGMAIN:{
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_CHANGE object:self userInfo:@{@"selectedIndex":[NSNumber numberWithInteger:3]}];
//        }
//            
//            break;
//        case MESSAGE_PINDETAIL:{
//            [self pushPinDetail:message.ref_id];
//        }
//            
//            break;
//        case MESSAGE_SUBJECTDETAIL:{
//            [self pushSubject:message.ref_id];
//        }
//            
//            break;
//            
//        default:
//            break;
//    }
//    
//}
//
- (void)initUserInfo
{
    DLogV(@"initUserInfo-----------------------------");
    
    if ([[NSThread currentThread] isMainThread]) {
        DLogV(@"main");
    } else {
        DLogV(@"not main");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        //do your UI
        DLogV(@"do your UI");
    });
    
    _loginUserInfomation = [Utils userInfomation];
    
    if (_loginUserInfomation != nil) {
        _loginUserId = _loginUserInfomation.info.user_id;
        _isLogin = _loginUserId > 0;
        
    } else {
        _isLogin = NO;
        _loginUserId = 0;
    }
    
}
//
//- (void)shareCommon:(NSString *)shareTitle shareDes:(NSString *)shareDes shareUrl:(NSString *)shareUrl shareImageUrl:(NSString *)shareImageUrl shareImage:(UIImage *)shareImage
//{
//    self.shareUrl = shareUrl;
//    self.shareTitle = shareTitle;
//    self.shareDes = shareDes;
//    self.shareImageUrl = shareImageUrl;
//    self.shareImage = shareImage;
//    
//    FSShareSheet *shareSheet = [[FSShareSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil];
//    [shareSheet show];
//    
//}
//
//- (void)shareUser:(UserInfoNoPin *)user
//{
//    //[MobClick event:@"shareUser"];
//    self.shareUrl = [NSString stringWithFormat:@"%@/user/%ld", HOST, user.user_id];
//    self.shareTitle = [NSString stringWithFormat:@"%@的萌宝拍主页", user.username];
//    self.shareDes = [NSString stringWithFormat:@"分享%@的萌宝拍主页，小伙伴们，快来围观！>> ", user.username];
//    if (user.avatar_id > 0) {
//        self.shareImageUrl = [Utils getImagePath:user.avatar tagWith:IMAGE_BIG];
//    } else {
//        self.shareImageUrl = [NSString stringWithFormat:@"%@/static/bidcms/img/apple-touch-icon-iphone4.png", HOST];
//    }
//    
//    if (user.avatar_id > 0) {
//        SDWebImageManager *manager = [SDWebImageManager sharedManager];
//        [manager downloadImageWithURL:[Utils getImagePathURL:user.avatar tagWith:IMAGE_NOR] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//            
//        } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//            
//            dispatch_async(dispatch_get_main_queue(), ^{
//                self.shareImage = image;
//                FSShareSheet *shareSheet = [[FSShareSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil];
//                if ([self loginUserId] == user.user_id) {
//                    [shareSheet showReportButton:NO];
//                } else {
//                    [shareSheet showReportButton:NO];
//                }
//                [shareSheet showDeleteButton:NO];
//                [shareSheet show];
//            });
//        }];
//    } else {
//        self.shareImage = ImageNamed(@"avatar");
//        FSShareSheet *shareSheet = [[FSShareSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil];
//        if ([self loginUserId] == user.user_id) {
//            [shareSheet showReportButton:NO];
//        } else {
//            [shareSheet showReportButton:NO];
//        }
//        [shareSheet showDeleteButton:NO];
//        [shareSheet show];
//    }
//    
//    
//}
//
//- (void)sharePin:(Pin *)pin;
//{
//    //[MobClick event:@"sharePin"];
//    self.shareUrl = [NSString stringWithFormat:@"%@/pins/%ld", HOST, pin.pin_id];
//    self.shareTitle = [NSString stringWithFormat:@"%@的萌宝拍", pin.user.username];
//    
//    if (pin.raw_text.length > 0) {
//        self.shareDes = [NSString stringWithFormat:@"分享%@的萌宝拍“%@”，小伙伴们，快来围观！>> ", pin.user.username, pin.raw_text];
//    } else {
//        self.shareDes = [NSString stringWithFormat:@"分享%@的萌宝拍，小伙伴们，快来围观！>> ", pin.user.username];
//    }
//    
//    self.shareImageUrl = [Utils getImagePath:pin.file tagWith:IMAGE_BIG];
//    
//    SDWebImageManager *manager = [SDWebImageManager sharedManager];
//    [manager downloadImageWithURL:[Utils getImagePathURL:pin.file tagWith:IMAGE_NOR] options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            self.shareImage = image;
//            FSShareSheet *shareSheet = [[FSShareSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil];
//            if ([self loginUserId] == pin.user_id) {
//                [shareSheet showReportButton:NO];
//                [shareSheet showDeleteButton:YES];
//            } else {
//                [shareSheet showReportButton:YES];
//            }
//            
//            [shareSheet show];
//        });
//        
//        
//    }];
//
//}
//
//- (void)sharePinPublished:(Pin *)pin;
//{
//    BabyShareView *shareView = [[BabyShareView alloc]initWidthPin:pin];
//    shareView.isUpload = YES;
//    [self showShareDialog:shareView];
//}
//
//- (void)shareSheet:(FSShareSheet *)shareView clickedButtonAtIndex:(NSInteger)index
//{
//    switch (index) {
//        case SHARE_WEIXIN:
//            [self shareToWeixin];
//            break;
//        case SHARE_PYQ:
//            [self shareToPyq];
//            break;
//        case SHARE_SINA:
//            [self shareToSina];
//            break;
//        case SHARE_QQ:
//            [self shareToQQ];
//            break;
//        case SHARE_QZONE:
//            [self shareToQzone];
//            break;
//        case SHARE_LINK:
//            [self shareToLink];
//            break;
//            
//        case SHARE_REPORT:
//            [self shareReport];
//            break;
//        case SHARE_DELETE:
//            [self shareDelete];
//            break;
//            
//        default:
//            break;
//    }
//}
//
//- (void) showShareDialog:(BabyShareView *)shareView
//{
//    shareView.shareViewPin = ^(NSInteger shareTo, NSString *shareTitle, NSString *shareDes, NSString *shareUrl, NSString *shareImageUrl, UIImage *shareImage){
//        
//        self.shareTitle = shareTitle;
//        self.shareDes = shareDes;
//        self.shareUrl = shareUrl;
//        self.shareImageUrl = shareImageUrl;
//        self.shareImage = shareImage;
//        
//        switch (shareTo) {
//            case SHARE_WEIXIN:
//                [self shareToWeixin];
//                break;
//            case SHARE_PYQ:
//                [self shareToPyq];
//                break;
//            case SHARE_SINA:
//                [self shareToSina];
//                break;
//            case SHARE_QQ:
//                [self shareToQQ];
//                break;
//            case SHARE_QZONE:
//                [self shareToQzone];
//                break;
//            case SHARE_LINK:
//                [self shareToLink];
//                break;
//                
//            default:
//                break;
//        }
//        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [_modal closeWithLeansRandom];
//        });
//        
//    };
//    shareView.closeButtonHandler = ^(void){
//        [_modal closeWithLeansRandom];
//    };
//    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    _modal = [PathDynamicModal showWithModalView:shareView inView:window];
//    _modal.showMagnitude = 100.0f;
//    _modal.closeMagnitude = 160.0f;
//}
//
//- (void)shareReport
//{
//    
//}
//
//- (void)shareDelete
//{
//    
//}
//
//- (void)shareToWeixin
//{
//    [UMSocialData defaultData].extConfig.wechatSessionData.title = _shareTitle;
//    [UMSocialData defaultData].extConfig.wechatSessionData.url = _shareUrl;
//    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
//    
//    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatSession] content:_shareDes image:_shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            DLogV(@"分享成功！");
//        }
//    }];
//}
//
//- (void)shareToPyq
//{
//    [UMSocialData defaultData].extConfig.wechatTimelineData.title = _shareDes;
//    [UMSocialData defaultData].extConfig.wechatTimelineData.url = _shareUrl;
//    [UMSocialData defaultData].extConfig.wxMessageType = UMSocialWXMessageTypeWeb;
//    
//    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToWechatTimeline] content:_shareDes image:_shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            DLogV(@"分享成功！");
//        }
//    }];
//}
//
//- (void)shareToSina
//{
//    UMSocialUrlResource *urlResource = [[UMSocialUrlResource alloc] initWithSnsResourceType:UMSocialUrlResourceTypeImage url:_shareImageUrl];
//    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToSina] content:[NSString stringWithFormat:@"%@%@",_shareDes,_shareUrl] image:nil location:nil urlResource:urlResource presentedController:self completion:^(UMSocialResponseEntity *shareResponse){
//        if (shareResponse.responseCode == UMSResponseCodeSuccess) {
//            DLogV(@"分享成功！");
//        }
//    }];
//}
//
//- (void)shareToQQ
//{
//    [UMSocialData defaultData].extConfig.qqData.title = _shareTitle;
//    [UMSocialData defaultData].extConfig.qqData.url = _shareUrl;
//    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQQ] content:_shareDes image:_shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            DLogV(@"分享成功！");
//        }
//    }];
//}
//
//- (void)shareToQzone
//{
//    [UMSocialData defaultData].extConfig.qzoneData.title = _shareTitle;
//    [UMSocialData defaultData].extConfig.qzoneData.url = _shareUrl;
//    [[UMSocialDataService defaultDataService]  postSNSWithTypes:@[UMShareToQzone] content:_shareDes image:_shareImage location:nil urlResource:nil presentedController:self completion:^(UMSocialResponseEntity *response){
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            DLogV(@"分享成功！");
//        }
//    }];
//}
//
//- (void)shareToLink
//{
//    [[UIPasteboard generalPasteboard] setPersistent:YES];
//    [[UIPasteboard generalPasteboard] setValue:_shareUrl forPasteboardType:[UIPasteboardTypeListString objectAtIndex:0]];
//    
//    [SVProgressHUD showSuccessWithStatus:@"成功复制到剪切板"];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [SVProgressHUD dismiss];
//    });
//}
//
//
//- (void)loginUser
//{
//    BabyLoginView *loginView = [[BabyLoginView alloc]init];
//    loginView.userTipClick = ^() {
//        [_modal closeWithLeansRandom];
//        TOWebViewController *webViewController = [[TOWebViewController alloc] initWithURL:[NSURL URLWithString:@"http://www.mengbaopai.com/baby_agreement.html"]];
//        webViewController.buttonTintColor = [UIColor whiteColor];
//        webViewController.buttonBottomTintColor = UIColorFromRGB(BABYCOLOR_base_color);
//        BabyNavigationController *webviewNav = [[BabyNavigationController alloc]initWithRootViewController:webViewController];
//        [self presentViewController:webviewNav animated:YES completion:nil];
//    };
//    loginView.loginWith = ^(NSInteger loginType){
//        [_modal closeWithLeansRandom];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            switch (loginType) {
//                case LOGIN_SINA:
//                    [self loginSina];
//                    break;
//                case LOGIN_QQ:
//                    [self loginQq];
//                    break;
//                case LOGIN_MOBILE:
//                    [self loginMobile];
//                    break;
//                default:
//                    break;
//            }
//        });
//    };
//    loginView.closeButtonHandler = ^(void){
//        [_modal closeWithLeansRandom];
//    };
//    
//    UIWindow *window = [UIApplication sharedApplication].keyWindow;
//    _modal = [PathDynamicModal showWithModalView:loginView inView:window];
//    _modal.showMagnitude = 100.0f;
//    _modal.closeMagnitude = 160.0f;
//    
//}
//
//- (void)loginSina
//{
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
//    
//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        [_modal closeWithLeansRandom];
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            [SVProgressHUD showWithStatus:@"登录中..."];
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
//            
//            _user_face = @"";
//            _login_type = WB_LOGIN;
//            _userName = snsAccount.userName;
//            _urlName = snsAccount.usid;
//            _openId = _accessToken = snsAccount.accessToken;
//            _iconURL = snsAccount.iconURL;
//            _expirationDate =  snsAccount.expirationDate;
//            [self loadUserFace];
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"微博授权失败请稍后再试"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//    });
//}
//
//- (void)loginQq
//{
//    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToQQ];
//    
//    snsPlatform.loginClickHandler(self,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
//        
//        [_modal closeWithLeansRandom];
//        if (response.responseCode == UMSResponseCodeSuccess) {
//            [SVProgressHUD showWithStatus:@"登录中..."];
//            UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToQQ];
//            
//            _user_face = @"";
//            _login_type = QQ_LOGIN;
//            _userName = snsAccount.userName;
//            _urlName = snsAccount.usid;
//            _accessToken = snsAccount.accessToken;
//            _iconURL = snsAccount.iconURL;
//            _openId = snsAccount.openId;
//            _expirationDate =  snsAccount.expirationDate;
//            [self loadUserFace];
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"QQ授权失败请稍后再试"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//        
//    });
//}
//
//
//- (void)loginMobile
//{
//    LoginMobileViewController *loginMobile = [[LoginMobileViewController alloc]init];
//    loginMobile.hidesBottomBarWhenPushed = YES;
//    BabyNavigationController *loginMobileNav = [[BabyNavigationController alloc]initWithRootViewController:loginMobile];
//    
//    [self presentViewController:loginMobileNav animated:YES completion:nil];
//    
//}
//
//- (void)loadUserFace
//{
//    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:_iconURL] options:0 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        // 下载进度block
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
//        // 下载完成block
//        [self uploadUserFace:image];
//        DLogV(@"加载图片完成");
//    }];
//}
//
//- (void)uploadUserFace:(UIImage *)image
//{
//    if (image != nil) {
//        _user_face = [StringUtils getDatePathWithFile:@"png"];
//        [UPYUNConfig sharedInstance].DEFAULT_BUCKET = @"babypai";
//        [UPYUNConfig sharedInstance].DEFAULT_PASSCODE = @"qNwsBxXxNBAaNh/QP5SQertO4GM=";
//        __block UpYun *uy = [[UpYun alloc] init];
//        uy.successBlocker = ^(NSURLResponse *response, id responseData) {
//            
//            NSDictionary *dict = [NSDictionary dictionaryWithObject:responseData forKey:@"url"];
//            DLogV(@"%@", dict);
//            _user_face = [[dict objectForKey:@"url"] objectForKey:@"url"];
//            [self SyncLogin];
//        };
//        uy.failBlocker = ^(NSError * error) {
//            _user_face = @"";
//            [self SyncLogin];
//        };
//        uy.progressBlocker = ^(CGFloat percent, int64_t requestDidSendBytes) {
//        };
//        
//        [uy uploadImage:image savekey:_user_face];
//    } else {
//        _user_face = @"";
//        [self SyncLogin];
//    }
//    
//}
//
//- (void)SyncLogin
//{
//    DataCompletionBlock completionBlock = ^(NSDictionary *data, NSString *errorString){
//        
//        //shua xin stop
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//        
//        if (data != nil) {
//            UserInfomation *userInfo = [UserInfomation mj_objectWithKeyValues:data];
//            
//            if (userInfo.msg > 0) {
//                [SVProgressHUD showErrorWithStatus:userInfo.error];
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];
//                });
//            } else {
//                if ([Utils userId] > 0) {
//                    [SVProgressHUD showSuccessWithStatus:@"绑定成功"];
//                } else {
//                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"欢迎您：%@", userInfo.info.username]];
//                }
//                [Utils updataUserInfo:errorString];
//                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];
//                });
//                [self initUserInfo];
//            }
//            
//        } else {
//            [SVProgressHUD showErrorWithStatus:@"登录失败，请稍后再试"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//        }
//    };
//    
//    
//    BabyDataSource *souce = [BabyDataSource dataSource];
//    
//    NSString *fields = [NSString stringWithFormat:@"{\"user_id\":\"%ld\",\"login_type\":\"%@\",\"openid\":\"%@\",\"access_token\":\"%@\",\"expires_in\":\"%@\",\"wb_id\":\"%@\",\"nickname\":\"%@\",\"urlname\":\"%@\",\"user_face\":\"%@\",\"file_path\":\"%@\"}", [Utils userId], _login_type, _openId, _accessToken, @"7776000", _urlName, _userName, _urlName, _user_face, [StringUtils getDatePath]];
//    
//    if ([Utils userId] > 0) {
//        [souce getData:BIND_SYNC parameters:fields completion:completionBlock];
//    } else {
//        [souce getData:LOGIN_SYNC parameters:fields completion:completionBlock];
//    }
//    
//}
//
//- (void)pinLikePost:(Pin *)pin withLike:(NSString *)like
//{
//    //[MobClick event:@"likePin"];
//    DataCompletionBlock completionBlock = ^(NSDictionary *data, NSString *errorString){
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    };
//    
//    
//    BabyDataSource *souce = [BabyDataSource dataSource];
//    
//    NSString *fields = [NSString stringWithFormat:@"{\"pinId\":\"%ld\",\"user_id\":\"%ld\",\"doLike\":\"%@\"}", pin.pin_id, [self loginUserId], like];
//    [souce getData:PIN_LIKE parameters:fields completion:completionBlock];
//}
//
//- (void)uploadPin
//{
//    
//    [JDStatusBarNotification addStyleNamed:@"style" prepare:^JDStatusBarStyle *(JDStatusBarStyle *style) {
//        
//        style.textColor = [UIColor whiteColor];
//        style.barColor = UIColorFromRGB(BABYCOLOR_base_color);
//        
//        
//        style.progressBarColor = [UIColor whiteColor];
//        //                style.progressBarPosition = self.progressBarPosition;
//        
//        return style;
//    }];
//    [JDStatusBarNotification showWithStatus:@"正在上传" styleName:@"style"];
//    
//    //[MobClick event:@"uploadPin"];
//    [[BabyPinUpload upload] startUploadWithCompletion:^(NSString *data, NSString *errorString) {
//        DLog(@"上传成功 : %@, errorString : %@", data, errorString);
//        
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //回调或者说是通知主线程刷新，
//            [JDStatusBarNotification dismissAnimated:YES];
//            
//        });
//        
//    } progress:^(float progress) {
//        DLog(@"上传进度 ： %f", progress);
//        
//        dispatch_async(dispatch_get_main_queue(), ^{
//            //回调或者说是通知主线程刷新，
//            [JDStatusBarNotification showProgress:progress];
//            
//        });
//        
//    }];
//}
//

- (void)startNetworkReachability
{
    _reachabilityMannger =   [AFNetworkReachabilityManager sharedManager];
    
    [_reachabilityMannger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSString *result = @"";
        switch (status) {
            case AFNetworkReachabilityStatusUnknown:
                result = @"未知网络";
                break;
            case AFNetworkReachabilityStatusNotReachable:
                result = @"无网络";
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                result = @"WAN";
                _isNetworkWAN = YES;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                result = @"WIFI";
                _isNetworkWAN = NO;
                break;
                
            default:
                break;
        }
        DLogV(@"NetworkReachability : %@",result);
    }];
    
    [_reachabilityMannger startMonitoring];
}

- (void)stopNetworkReachability
{
    if (_reachabilityMannger) {
        [_reachabilityMannger stopMonitoring];
    }
}

@end
