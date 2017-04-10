//
//  AppAppearance.m
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AppAppearance.h"

@implementation AppAppearance

+(instancetype)sharedAppearance
{
    static AppAppearance* instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype) init
{
    if ([super init]) {
        _mainColor             = UIColorFromRGB(0xfe3479);
        _alertBackgroundColor  = [UIColor colorWithRed:64/255 green:64/255 blue:64/255 alpha:0.4];
        
        _defaultImage       = [UIImage imageNamed:@"default_serve_image"];
    }
    return self;
}

@end
