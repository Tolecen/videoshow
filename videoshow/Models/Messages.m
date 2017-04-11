//
//  Messages.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Messages.h"
#import "MJExtension.h"
#import "Message.h"

@implementation Messages

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [Message class] };
}

@end
