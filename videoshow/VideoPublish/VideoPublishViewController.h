//
//  VideoPublishViewController.h
//  Babypai
//
//  Created by ning on 16/5/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyBaseVC.h"
#import "BabyUploadEntity.h"
#import "MediaObject.h"

#import <IJKMediaFramework/IJKMediaPlayback.h>
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>


@interface VideoPublishViewController : BabyBaseVC

@property(nonatomic, strong) BabyUploadEntity *uploadEntity;

@property(nonatomic, assign) BOOL fromDraft;

@property(nonatomic, strong) NSString *imagePath;

@property(nonatomic, copy) void(^savedDraft) (BOOL saved);
@property(nonatomic, copy) void(^onPublish) ();

@property (nonatomic, strong) NSArray *videoFilter;

/**
 * 临时合并视频流
 */
@property (nonatomic, strong) NSString *mVideoTempPath;


@property(nonatomic, strong) MediaObject *mMediaObject;


@property(atomic, retain) id<IJKMediaPlayback> player;

@end
