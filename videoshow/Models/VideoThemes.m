//
//  VideoThemes.m
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoThemes.h"
#import "MJExtension.h"

@implementation VideoThemes

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [VideoTheme class] };
}

@end
