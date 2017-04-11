//
//  Mention.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface Mention : NSObject

@property (nonatomic, assign) long mention_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, assign) long post_owner_id;
@property (nonatomic, assign) long post_id;
@property (nonatomic, assign) long post_author_id;
@property (nonatomic, assign) long posted_at;
@property (nonatomic, copy) NSString *post_type;
@property (nonatomic, assign) long start;
@property (nonatomic, assign) long offset;
@property (nonatomic, strong) User *user;

@end
