//
//  Tags.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Tags.h"
#import "Tag.h"
#import "MJExtension.h"

@implementation Tags

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"banner_tags" : [Tag class] , @"other_tags" : [Tag class] };
}

@end
