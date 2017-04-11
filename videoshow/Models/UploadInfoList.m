//
//  UploadInfoList.m
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import "UploadInfoList.h"
#import "MJExtension.h"
#import "UploadInfo.h"

@implementation UploadInfoList

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"info" : [UploadInfo class] };
}

@end
