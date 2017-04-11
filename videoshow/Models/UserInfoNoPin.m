//
//  UserInfoNoPin.m
//  Babypai
//
//  Created by ning on 16/2/28.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "UserInfoNoPin.h"
#import "MJExtension.h"

@implementation UserInfoNoPin

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"bindings" : [UserBind class] };
}
@end
