//
//  Users.m
//  Babypai
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//
#import "Users.h"
#import "MJExtension.h"

@implementation Users

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [UserInfo class] };
}

@end
