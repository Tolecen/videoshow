//
//  UserInfoNoPin.h
//  Babypai
//
//  Created by ning on 16/2/28.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"
#import "UserBind.h"
#import "UserProfile.h"

@interface UserInfoNoPin : NSObject

@property (nonatomic, assign) long user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *urlname;
@property (nonatomic, copy) NSString *mobile;
@property (nonatomic, assign) long created_at;
@property (nonatomic, assign) long avatar_id;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *location;
@property (nonatomic, assign) long board_count;
@property (nonatomic, assign) long pin_count;
@property (nonatomic, assign) long like_count;
@property (nonatomic, assign) long follower_count;
@property (nonatomic, assign) long following_count;
@property (nonatomic, assign) long rating;
@property (nonatomic, assign) long following;
@property (nonatomic, strong) BabyFile *avatar;
@property (nonatomic, strong) NSMutableArray *bindings;
@property (nonatomic, strong) UserProfile *profile;

@end
