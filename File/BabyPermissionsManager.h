//
//  BabyPermissionsManager.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyPermissionsManager : NSObject

- (void)checkMicrophonePermissionsWithBlock:(void(^)(BOOL granted))block;
- (void)checkCameraAuthorizationStatusWithBlock:(void(^)(BOOL granted))block;

@end
