//
//  User.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"

@interface User : NSObject

@property (nonatomic, assign) long user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *urlname;
@property (nonatomic, assign) long created_at;
@property (nonatomic, assign) long avatar_id;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) BabyFile *avatar;

@end
