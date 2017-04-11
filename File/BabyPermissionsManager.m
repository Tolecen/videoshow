//
//  BabyPermissionsManager.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyPermissionsManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MacroDefinition.h"

@interface BabyPermissionsManager()


@end

@implementation BabyPermissionsManager

- (void)checkMicrophonePermissionsWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeAudio;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
//        if(!granted){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动麦克风"
//                                                                message:@"请为萌宝拍打开麦克风权限：手机设置->隐私->麦克风->萌宝拍（打开）"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"确定"
//                                                      otherButtonTitles:@"去设置", nil];
//                [alert show];
//            });
//        }
        if(block != nil)
            block(granted);
    }];
}


- (void)checkCameraAuthorizationStatusWithBlock:(void(^)(BOOL granted))block
{
    NSString *mediaType = AVMediaTypeVideo;
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
//        if (!granted){
//            //Not granted access to mediaType
//            dispatch_async(dispatch_get_main_queue(), ^{
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"无法启动相机"
//                                                                message:@"请为萌宝拍打开相机权限：手机设置->隐私->相机->萌宝拍（打开）"
//                                                               delegate:self
//                                                      cancelButtonTitle:@"确定"
//                                                      otherButtonTitles:@"去设置", nil];
//                
//                [alert show];
//            });
//        }
        if(block)
            block(granted);
    }];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"buttonIndex : %ld", (long)buttonIndex);
    if(buttonIndex == 1){
//        Bundle Identifier
        NSString *app_id = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleIdentifier"];
        NSString *app_id2 = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"Bundle Identifier"];
        DLog(@"app_id2 : %@", app_id2);
        NSURL *setUrl = [NSURL URLWithString:[NSString stringWithFormat: @"prefs:root=%@", app_id ]];
        DLog(@"setUrl : %@", setUrl);
        [[UIApplication sharedApplication] openURL:setUrl];
        
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
    }
}

@end
