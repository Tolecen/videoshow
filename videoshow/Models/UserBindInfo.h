//
//  UserBindInfo.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"

@interface UserBindInfo : NSObject

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *username;
@property (nonatomic, copy) NSString *urlname;
@property (nonatomic, copy) NSString *email;
@property (nonatomic, strong) BabyFile *avatar;

@end
