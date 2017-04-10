//
//  NSDictionary+LocalLog.m
//  videoshow
//
//  Created by gutou on 2017/3/25.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "NSDictionary+LocalLog.h"

@implementation NSDictionary (LocalLog)

#if DEBUG
- (NSString *)descriptionWithLocale:(nullable id)locale{
    
    return [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding];
}
#endif

@end
