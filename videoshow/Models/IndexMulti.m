//
//  IndexMulti.m
//  Babypai
//
//  Created by ning on 16/5/25.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "IndexMulti.h"
#import "MJExtension.h"
#import "Tag.h"

@implementation IndexMulti

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"subjects" : [SubjectInfo class], @"hotPins" : [Pin class], @"tags" : [Tag class] };
}

@end
