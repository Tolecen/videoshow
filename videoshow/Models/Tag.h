//
//  Tag.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"

@interface Tag : NSObject

@property (nonatomic, assign) long tag_id;
@property (nonatomic, copy) NSString *tag_name;
@property (nonatomic, copy) NSString *tag_description;
@property (nonatomic, assign) int isused;
@property (nonatomic, assign) int tag_type;
@property (nonatomic, assign) int tag_sort;
@property (nonatomic, assign) long file_id;
@property (nonatomic, assign) long created_time;
@property (nonatomic, strong) BabyFile *file;
@property (nonatomic, strong) NSMutableArray *pins;

@end
