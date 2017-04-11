//
//  UserInfos.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "UserInfos.h"
#import "MJExtension.h"

@implementation UserInfos

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [UserInfo class] };
}

@end
