//
//  Comments.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "Comments.h"
#import "MJExtension.h"
#import "Comment.h"

@implementation Comments

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"info" : [Comment class]};
}

@end
