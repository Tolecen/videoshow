//
//  Topics.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Topics.h"
#import "MJExtension.h"
#import "Topic.h"

@implementation Topics

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"topic" : [Topic class] };
}

@end
