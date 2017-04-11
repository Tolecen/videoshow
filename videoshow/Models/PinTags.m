//
//  PinTags.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "PinTags.h"
#import "MJExtension.h"
#import "PinTag.h"

@implementation PinTags

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"tag" : [PinTag class] };
}

@end
