//
//  Messages.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Messages : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) NSMutableArray *info;

@end
