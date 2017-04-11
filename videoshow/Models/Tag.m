//
//  Tag.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Tag.h"
#import "MJExtension.h"
#import "Pin.h"

@implementation Tag

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"pins" : [Pin class] };
}

@end
