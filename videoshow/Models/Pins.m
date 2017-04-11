//
//  Pins.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Pins.h"
#import "MJExtension.h"
#import "Pin.h"

@implementation Pins

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [Pin class] };
}

@end
