//
//  Board.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Board.h"
#import "MJExtension.h"

@implementation Board

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"pins" : [Pin class] };
}

@end
