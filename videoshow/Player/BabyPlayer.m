//
//  BabyPlayer.m
//  Babypai
//
//  Created by ning on 16/5/9.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyPlayer.h"
#import <IJKMediaFramework/IJKMediaFramework.h>
#import "BabyMediaControl.h"
#import "MacroDefinition.h"

@interface BabyPlayer ()

@property(atomic, retain) id<IJKMediaPlayback> player;
@property(nonatomic, strong) BabyMediaControl *mediaControl;

@property (nonatomic, assign) BOOL bufferEmpty;
@property (nonatomic, assign) BOOL loaded;


@end

@implementation BabyPlayer

+ (id)babyPlayer
{
    static BabyPlayer *babyplayer = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        babyplayer = [[self alloc]init];
        
    });
    
    return babyplayer;
}

- (void)initWithFrame:(CGRect)frame withvideoPath:(NSString *)videoPath
{
    DLog(@"videoPath is %@", videoPath);
    self.frame = frame;
    
    _URL = [NSURL URLWithString:videoPath];
    [self playVideoLocal];
//    self.mCircleProgress = [[CircleProgress alloc] initWithCenter:CGPointMake((self.bounds.size.width) / 2, (self.bounds.size.height) / 2)
//                                                           radius:kMediaPlayProgressWH
//                                                        lineWidth:kMediaPlayProgressWH
//                                                     progressMode:THProgressModeFill
//                                                    progressColor:[UIColor grayColor]
//                                           progressBackgroundMode:THProgressBackgroundModeCircle
//                                          progressBackgroundColor:[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:0.6f]
//                                                       percentage:0.0f];
//    self.mCircleProgress.layer.zPosition = 1001;
//    [self addSubview:self.mCircleProgress];
//    
//    __weak typeof(self) weakSelf = self;
//    self.mDownloadProgressBlock = ^(float progress){
//        if(weakSelf.mCircleProgress != nil) {
//            weakSelf.mCircleProgress.percentage = progress;
//        }
//    };
//    
//    self.mDownloadCompletionBlock = ^(NSString* data, NSString* errorString){
//        if(weakSelf.mCircleProgress != nil)
//            [weakSelf.mCircleProgress removeFromSuperview];
//        if(errorString == nil)
//            [weakSelf playVideoLocal];
//    };
//    
//    VideoDownloader *mVideoDownloader = [VideoDownloader videoDownloader];
//    [mVideoDownloader downloadVideo:videoPath completion:self.mDownloadCompletionBlock progress:self.mDownloadProgressBlock];
}

-(void)playVideoLocal
{
    [self setupPlayer];
}

-(void)dealloc {
    
    [self destroyPlayer];
    
}

-(instancetype)init {
    
    self = [super init];
    if (self) {
        
        
        // setup internal
        
        [self setEndAction:BabyPlayerEndActionStop];
        [self setState:BabyPlayerStateStopped];
        
    }
    return self;
    
}

#pragma mark - Actions

-(void)play {
    
    switch ([self state]) {
        case BabyPlayerStatePaused:
            
            [[self player] play];
            
            break;
        case BabyPlayerStateStopped:
            
            [self setupPlayer];
            
            break;
            
        default:
            break;
    }
    
}

-(void)pause {
    
    if ([self state] == BabyPlayerStatePaused ||
        [self state] == BabyPlayerStateStopped) return;
    [self.mediaControl showNoFade];
    [[self player] pause];
    
}

-(void)stop {
    
    if ([self state] != BabyPlayerStateStopped) return;
    
    [self destroyPlayer];
    
}

#pragma mark - Player

-(void)setupPlayer {
    
    if (![self URL]) return;
    
    [self destroyPlayer];
    
    [self installMovieNotificationObservers];
    
    // 设置view
    
    self.player = [[IJKAVMoviePlayerController alloc] initWithContentURL:self.URL];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.bounds;
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    self.autoresizesSubviews = YES;
    [self addSubview:self.player.view];
    
    self.mediaControl = [[BabyMediaControl alloc]initWithFrame:self.bounds];
    
    [self addSubview:self.mediaControl];
    
    self.mediaControl.delegatePlayer = self.player;
    [self.mediaControl hideAndRefresh];
    
    [self.player prepareToPlay];
    
    [self layoutSubviews];
    
}

-(void)destroyPlayer {
    if (self.player) {
        [self.player shutdown];
    }
    [self.mediaControl removeFromSuperview];
    [self setMediaControl:nil];
    self.delegate = nil;
    [self setPlayer:nil];
    [self setStateNotifyingDelegate:BabyPlayerStateStopped];
    [self removeMovieNotificationObservers];
    
}


-(void)playerFailed {
    
    [self destroyPlayer];
    
    if ([[self delegate] respondsToSelector:@selector(videoPlayer:encounteredError:)])
        [[self delegate] videoPlayer:self encounteredError:[NSError errorWithDomain:@"BabyPlayer" code:1 userInfo:@{ NSLocalizedDescriptionKey : @"An unknown error occurred." }]];
    
}

-(void)setState:(BabyPlayerState)state {
    
    _state = state;
    
    switch (state) {
        case BabyPlayerStatePaused:
        case BabyPlayerStateStopped:
            self.playing = false;
            break;
        case BabyPlayerStateLoading:
        case BabyPlayerStatePlaying:
            self.playing = true;
            break;
        default:
            break;
    }
    
}

#pragma mark - Delegate

-(void)setStateNotifyingDelegate:(BabyPlayerState)state {
    
    BabyPlayerState previousState = [self state];
    [self setState:state];
    
    if (state != previousState) {
        
        if ([[self delegate] respondsToSelector:@selector(videoPlayer:changedState:)])
            [[self delegate] videoPlayer:self changedState:state];
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    
    switch (reason)
    {
        case IJKMPMovieFinishReasonPlaybackEnded:
            DLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            DLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            DLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            [self playerFailed];
            break;
            
        default:
            DLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    [_mediaControl showLoading:NO];
    DLogE(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward
    
    switch (_player.playbackState)
    {
        case IJKMPMoviePlaybackStateStopped: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            [self setStateNotifyingDelegate:BabyPlayerStatePlaying];
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            [self setStateNotifyingDelegate:BabyPlayerStatePaused];
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            [self setStateNotifyingDelegate:BabyPlayerStateLoading];
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            DLogE(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        DLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        DLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        DLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:IJKMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:IJKMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:IJKMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:IJKMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

@end
