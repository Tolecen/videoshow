//
//  SubjectInfo.h
//  Babypai
//
//  Created by ning on 16/5/25.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"

@interface SubjectInfo : NSObject

@property(nonatomic, assign) long activity_id;
@property(nonatomic, assign) long author_id;
@property(nonatomic, strong) NSString *activity_title;
@property(nonatomic, strong) NSString *activity_des;
@property(nonatomic, assign) int activity_type;
@property(nonatomic, assign) int activity_sort;
@property(nonatomic, assign) long file_id;
@property (nonatomic, strong) BabyFile *file;
@property(nonatomic, assign) long read_count;
@property(nonatomic, assign) long like_count;
@property(nonatomic, assign) long agent_android_count;
@property(nonatomic, assign) long agent_ios_count;
@property(nonatomic, assign) long agent_other_count;
@property(nonatomic, assign) long created_at;

@end
