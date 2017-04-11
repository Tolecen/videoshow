//
//  Topic.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Topic : NSObject

@property (nonatomic, assign) long topic_id;
@property (nonatomic, copy) NSString *topic_name;
@property (nonatomic, assign) int isused;
@property (nonatomic, copy) NSString *topic_desc;
@property (nonatomic, copy) NSString *topic_tag;
@property (nonatomic, copy) NSString *topic_weibo;
@property (nonatomic, assign) long created_time;
@property (nonatomic, assign) long end_time;

@end
