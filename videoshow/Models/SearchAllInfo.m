//
//  SearchAllInfo.m
//  Buole
//
//  Created by ning on 16/7/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "SearchAllInfo.h"
#import "MJExtension.h"
#import "User.h"
#import "Pin.h"

@implementation SearchAllInfo

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"pins" : [Pin class], @"users" : [User class] };
}

@end
