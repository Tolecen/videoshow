//
//  CommentTextMeta.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "CommentTextMeta.h"
#import "MJExtension.h"
#import "Mention.h"

@implementation CommentTextMeta

+ (NSDictionary *)mj_objectClassInArray
{
    return @{@"mentions" : [Mention class]};
}

@end
