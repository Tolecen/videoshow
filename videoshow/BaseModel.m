//
//  BaseModel.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseModel.h"

@implementation BaseModel

//应用实例 ---- >>>> 在  lz_VideoTemplateModel.h 类中

- (void) serializeWithDictionary:(NSDictionary*)dictionary
{
    NSLog(@"%@ %s 子类需要重写这个方法！", NSStringFromClass(self.class), __FUNCTION__);
}

+ (NSDictionary *) pathsByPropertyKey
{
    return @{};
}

+ (NSDictionary *) JSONKeyPathsByPropertyKey
{
    return [self pathsByPropertyKey];
}

/*
     + (NSDictionary *) pathsByPropertyKey
     {
     NSMutableDictionary * dic = [NSMutableDictionary dictionary];
     [dic addEntriesFromDictionary:[super pathsByPropertyKey]];
     [dic addEntriesFromDictionary:@{@"修改名称":@"原名"}];
     return dic;
     }
 */

@end
