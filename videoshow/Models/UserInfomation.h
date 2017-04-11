//
//  UserInfomation.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface UserInfomation : NSObject

@property (nonatomic, assign) int msg;
@property(nonatomic, strong) NSString *error;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) UserInfo *info;

@end
