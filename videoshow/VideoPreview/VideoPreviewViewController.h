//
//  VideoPreviewViewController.h
//  Babypai
//
//  Created by ning on 16/5/5.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "MediaObject.h"
#import "BabyBaseVC.h"
#import "BabyMediaControl.h"

typedef NS_ENUM(NSInteger, BABYVIDEO_THEME_FILTER) {
    BABYVIDEO_THEME,
    BABYVIDEO_FILTER,
};

@interface VideoPreviewViewController : BabyBaseVC

@property(atomic, retain) id<IJKMediaPlayback> player;
@property(nonatomic, strong) BabyMediaControl *mediaControl;
@property(nonatomic, strong) MediaObject *mMediaObject;

@property(nonatomic, assign) long tag_id;
@property(nonatomic, strong) NSString *tag;
@property(nonatomic, assign) BOOL fromDraft;
@property(nonatomic, assign) CGFloat outputHeight;
@property (nonatomic,assign)BOOL isCircle;

- (id)initWithMediaObject:(MediaObject *)mediaObject;

- (id)initWithVideoUrl:(NSString *)url;

@property(nonatomic, copy) void(^savedDraft) (BOOL saved);
@property(nonatomic, copy) void(^onPublish) ();

@end
