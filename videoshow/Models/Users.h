//
//  Users.h
//  Babypai
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserInfo.h"

@interface Users : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) NSMutableArray *info;

@end
