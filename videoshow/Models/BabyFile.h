//
//  BabyFile.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyFile : NSObject

@property (nonatomic, copy) NSString *key;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, copy) NSString *farm;
@property (nonatomic, copy) NSString *bucket;
@property (nonatomic, copy) NSString *host;
@property (nonatomic, assign) int frames;

@end
