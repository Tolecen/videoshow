//
//  Text_meta.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Text_meta.h"
#import "MJExtension.h"
#import "PinTag.h"

@implementation Text_meta

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"tags" : [PinTag class] };
}

@end
