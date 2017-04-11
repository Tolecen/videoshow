//
//  UserBind.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserBindInfo.h"

@interface UserBind : NSObject

@property (nonatomic, assign) long bind_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, copy) NSString *service_name;
@property (nonatomic, strong) UserBindInfo *user;

@end
