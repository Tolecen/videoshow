//
//  BabyPlayer.h
//  Babypai
//
//  Created by ning on 16/5/9.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CircleProgress.h"
#import "VideoDownloader.h"

typedef NS_ENUM(NSInteger, BabyPlayerState) {
    
    BabyPlayerStateStopped,
    BabyPlayerStateLoading,
    BabyPlayerStatePlaying,
    BabyPlayerStatePaused
    
};

typedef NS_ENUM(NSInteger, BabyPlayerEndAction) {
    
    BabyPlayerEndActionStop,
    BabyPlayerEndActionLoop
    
};

#define kMediaPlayWH 80
#define kMediaPlayProgressWH 40

@protocol BabyPlayerDelegate;

@interface BabyPlayer : UIView

@property(nonatomic,strong) UIImageView *playButton;
@property(nonatomic,strong) UIProgressView *mediaProgress;
@property (nonatomic, strong) CircleProgress *mCircleProgress;

@property (nonatomic, strong) DownloadProgressBlock mDownloadProgressBlock;
@property (nonatomic, strong) DownloadCompletionBlock mDownloadCompletionBlock;

- (void)initWithFrame:(CGRect)frame withvideoPath:(NSString *)videoPath;

@property (nonatomic, weak) id <BabyPlayerDelegate> delegate;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) BabyPlayerEndAction endAction;
@property (nonatomic, assign) BabyPlayerState state;

@property (nonatomic, assign, getter = isMuted) BOOL muted;
@property (nonatomic, assign) BOOL playing;

- (void)play;
- (void)pause;
- (void)stop;
- (void)destroyPlayer;
+ (id)babyPlayer;

@end

@protocol BabyPlayerDelegate <NSObject>

@optional
-(void)videoPlayer:(BabyPlayer *)videoPlayer changedState:(BabyPlayerState)state;
-(void)videoPlayer:(BabyPlayer *)videoPlayer encounteredError:(NSError *)error;

@end
