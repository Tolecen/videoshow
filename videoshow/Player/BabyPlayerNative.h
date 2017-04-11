//
//  BabyPlayerNative.h
//  Babypai
//
//  Created by ning on 16/2/21.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "CircleProgress.h"
#import "VideoDownloader.h"

typedef NS_ENUM(NSInteger, BabyPlayerNativeState) {
    
    BabyPlayerNativeStateStopped,
    BabyPlayerNativeStateLoading,
    BabyPlayerNativeStatePlaying,
    BabyPlayerNativeStatePaused
    
};

typedef NS_ENUM(NSInteger, BabyPlayerNativeEndAction) {
    
    BabyPlayerNativeEndActionStop,
    BabyPlayerNativeEndActionLoop
    
};

#define kMediaPlayWH 80
#define kMediaPlayProgressWH 40

@protocol BabyPlayerNativeDelegate;

@interface BabyPlayerNative : UIView

@property(nonatomic,strong) UIImageView *playButton;
@property(nonatomic,strong) UIProgressView *mediaProgress;
@property (nonatomic, strong) CircleProgress *mCircleProgress;

@property (nonatomic, strong) DownloadProgressBlock mDownloadProgressBlock;
@property (nonatomic, strong) DownloadCompletionBlock mDownloadCompletionBlock;

- (void)initWithFrame:(CGRect)frame withvideoPath:(NSString *)videoPath;

@property (nonatomic, weak) id <BabyPlayerNativeDelegate> delegate;

@property (nonatomic, strong) NSURL *URL;

@property (nonatomic, assign) BabyPlayerNativeEndAction endAction;
@property (nonatomic, assign) BabyPlayerNativeState state;

@property (nonatomic, assign, getter = isMuted) BOOL muted;
@property (nonatomic, assign) BOOL playing;

-(void)play;
-(void)pause;
-(void)stop;

- (void)refreshMediaControl;

+ (id)babyPlayer;

@end

@protocol BabyPlayerNativeDelegate <NSObject>

@optional
-(void)videoPlayer:(BabyPlayerNative *)videoPlayer changedState:(BabyPlayerNativeState)state;
-(void)videoPlayer:(BabyPlayerNative *)videoPlayer encounteredError:(NSError *)error;

@end
