//
//  UploadInfo.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UploadInfo : NSObject

@property (nonatomic, copy) NSString *file_image_original;
@property (nonatomic, copy) NSString *file_image_path;
@property (nonatomic, copy) NSString *file_video_path;
@property (nonatomic, copy) NSString *file_video_obj;
@property (nonatomic, copy) NSString *file_format;
@property (nonatomic, assign) int file_progress;
@property (nonatomic, assign) long file_time;
@property (nonatomic, assign) int file_isupload;
@property (nonatomic, assign) long user_id;
@property (nonatomic, assign) long board_id;
@property (nonatomic, copy) NSString *board_name;
@property (nonatomic, copy) NSString *raw_text;
@property (nonatomic, copy) NSString *at_uid;
@property (nonatomic, copy) NSString *tags;
@property (nonatomic, assign) int is_private;
@property (nonatomic, assign) int share_qq;
@property (nonatomic, assign) int share_wb;
@property (nonatomic, assign) int share_wx;
@property (nonatomic, assign) int is_draft;
@property (nonatomic, assign) int is_publish;

@end
