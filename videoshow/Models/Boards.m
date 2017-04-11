//
//  Boards.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Boards.h"
#import "MJExtension.h"

@implementation Boards

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [Board class] };
}

@end
