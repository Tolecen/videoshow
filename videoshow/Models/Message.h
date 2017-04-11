//
//  Message.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import "Pin.h"

@interface Message : NSObject

@property (nonatomic, assign) long feed_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, strong) UserInfoNoPin *user;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) long pin_id;
@property (nonatomic, strong) Pin *pin;
@property (nonatomic, assign) long comment_id;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, assign) long create_at;
@property (nonatomic, assign) int isview;

@end
