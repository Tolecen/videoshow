//
//  Comment.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CommentTextMeta.h"
#import "UserInfoNoPin.h"

@interface Comment : NSObject

@property (nonatomic, assign) long comment_id;
@property (nonatomic, assign) long pin_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, copy) NSString *raw_text;
@property (nonatomic, strong) CommentTextMeta *text_meta;
@property (nonatomic, assign) long created_at;
@property (nonatomic, assign) long like_count;
@property (nonatomic, assign) long liked;
@property (nonatomic, strong) UserInfoNoPin *user;

@end
