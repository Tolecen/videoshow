//
//  PostMessage.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostMessage : NSObject

@property (nonatomic, assign) int msg;
@property(nonatomic, strong) NSString *error;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, copy) NSString *info;

@end
