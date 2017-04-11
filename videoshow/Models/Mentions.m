//
//  Mentions.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Mentions.h"
#import "MJExtension.h"
#import "Mention.h"

@implementation Mentions

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"mention" : [Mention class]};
}

@end
