//
//  MentionTips.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "MentionTips.h"
#import "MJExtension.h"
#import "MentionTip.h"

@implementation MentionTips

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"MentionTip" : [MentionTip class] };
}

@end
