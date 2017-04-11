//
//  VideoThemes.h
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VideoTheme.h"

@interface VideoThemes : NSObject

@property (nonatomic, assign) int msg;
@property(nonatomic, strong) NSString *error;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) NSMutableArray *info;

@end
