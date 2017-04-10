//
//  BaseShareViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/3.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UMSocialCore/UMSocialCore.h>


typedef void(^ShareMessageBlock)(id result,NSError *error);

@interface BaseShareViewController : UIViewController

@property (nonatomic, strong) UMSocialMessageObject *messageObject;//

@property (nonatomic, copy) ShareMessageBlock ShareMessageBlock;

- (void) showWithViewController:(id)viewController;

//使用范例  
/**
 *      BaseShareViewController *vc = [[BaseShareViewController alloc] init];
 *      vc.messageObject = messageObject;
 *
 *      [vc showWithViewController:self];
 */


/*
     NSString *shareTitle             = @"小视秀 xxx";
     
     NSString *shareText              = @"点我进入小视秀";
     
     NSString *shareUrl               = @"url";
     
     //创建分享消息对象
     UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
     
     //创建网页内容对象
     //    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:@"分享标题" descr:@"分享内容描述" thumImage:[UIImage imageNamed:@"icon"]];
     NSString* thumbURL =  @"http://m.ayilaile.com/ayapp/ad/1/img/img_logo.png";
     
     UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:shareTitle descr:shareText thumImage:thumbURL];
     //设置网页地址
     shareObject.webpageUrl = shareUrl;
     
     //分享消息对象设置分享内容对象
     messageObject.shareObject = shareObject;
     
     BaseShareViewController *vc = [[BaseShareViewController alloc] init];
     vc.messageObject = messageObject;
     
     [vc showWithViewController:self];
 */


@end
