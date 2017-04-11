
//
//  UserInfo.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "UserInfo.h"
#import "MJExtension.h"

@implementation UserInfo

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"bindings" : [UserBind class] , @"pins" : [Pin class] };
}

@end
