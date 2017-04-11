//
//  Pin.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFile.h"
#import "PinBoard.h"
#import "UserInfoNoPin.h"
#import "Comment.h"

@interface Pin : NSObject

@property (nonatomic, assign) long pin_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, assign) long board_id;
@property (nonatomic, assign) long file_id;
@property (nonatomic, assign) long mp3_id;
@property (nonatomic, assign) long video_id;
@property (nonatomic, assign) long mp3_length;
@property (nonatomic, assign) long video_length;
@property (nonatomic, assign) long like_count;
@property (nonatomic, assign) long comment_count;
@property (nonatomic, assign) int is_private;
@property (nonatomic, copy) NSString *raw_text;
@property (nonatomic, assign) long tag_id;
@property (nonatomic, assign) int media_type;
@property (nonatomic, assign) long created_at;
@property (nonatomic, assign) int level;
@property (nonatomic, assign) int play_times;
@property (nonatomic, assign) int province_id;
@property (nonatomic, assign) int city_id;
@property (nonatomic, assign) int area_id;
@property (nonatomic, copy) NSString *province;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *addr;
@property (nonatomic, assign) double longitude;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) NSString *keywords;
@property (nonatomic, strong) BabyFile *file;
@property (nonatomic, strong) BabyFile *file_mp3;
@property (nonatomic, strong) BabyFile *file_video;
@property (nonatomic, strong) PinBoard *board;
@property (nonatomic, assign) long liked;
@property (nonatomic, strong) NSMutableArray *like_user;
@property (nonatomic, strong) NSMutableArray *comment;
@property (nonatomic, strong) UserInfoNoPin *user;

@end
