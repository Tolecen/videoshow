//
//  Pin.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Pin.h"
#import "MJExtension.h"

@implementation Pin

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"like_user" : [UserInfoNoPin class], @"comment" : [Comment class] };
}

@end
