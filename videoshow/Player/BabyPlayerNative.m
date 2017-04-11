//
//  BabyPlayerNative.m
//  Babypai
//
//  Created by ning on 16/2/21.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyPlayerNative.h"
#import <AVFoundation/AVFoundation.h>
#import "MacroDefinition.h"

@interface BabyPlayerNative ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@property (nonatomic, assign) BOOL bufferEmpty;
@property (nonatomic, assign) BOOL loaded;


@end

@implementation BabyPlayerNative

+ (id)babyPlayer
{
    static BabyPlayerNative *babyplayer = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        babyplayer = [[self alloc]init];
        
    });
    
    return babyplayer;
}

- (void)initWithFrame:(CGRect)frame withvideoPath:(NSString *)videoPath
{
    NSLog(@"videoPath is %@", videoPath);
    NSLog(@"frame x is %f, y is %f, w is %f, h is %f", frame.origin.x, frame.origin.y, frame.size.width, frame.size.height);
    self.frame = frame;
    
    _URL = [NSURL URLWithString:videoPath];
    
    self.mCircleProgress = [[CircleProgress alloc] initWithCenter:CGPointMake((self.bounds.size.width) / 2, (self.bounds.size.height) / 2)
                                                           radius:kMediaPlayProgressWH
                                                        lineWidth:kMediaPlayProgressWH
                                                     progressMode:THProgressModeFill
                                                    progressColor:[UIColor grayColor]
                                           progressBackgroundMode:THProgressBackgroundModeCircle
                                          progressBackgroundColor:[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:0.6f]
                                                       percentage:0.0f];
    self.mCircleProgress.layer.zPosition = 1001;
    [self addSubview:self.mCircleProgress];
    
    __weak typeof(self) weakSelf = self;
    self.mDownloadProgressBlock = ^(float progress){
        NSLog(@"PinCell mDownloadProgressBlock is :%f", progress);
        if(weakSelf.mCircleProgress != nil) {
            weakSelf.mCircleProgress.percentage = progress;
        }
    };
    
    self.mDownloadCompletionBlock = ^(NSString* data, NSString* errorString){
        if(_mCircleProgress != nil)
            [weakSelf.mCircleProgress removeFromSuperview];
        if(errorString == nil)
            [weakSelf playVideoLocal];
    };
    
    VideoDownloader *mVideoDownloader = [VideoDownloader videoDownloader];
    [mVideoDownloader downloadVideo:videoPath completion:self.mDownloadCompletionBlock progress:self.mDownloadProgressBlock];
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
        
        [self setEndAction:BabyPlayerNativeEndActionStop];
        [self setState:BabyPlayerNativeStateStopped];
        
    }
    return self;
    
}

-(void)layoutSubviews {
    
    [super layoutSubviews];
    
    [self refreshMediaControl];
    
    
    
}

#pragma mark - Actions

-(void)play {
    
    switch ([self state]) {
        case BabyPlayerNativeStatePaused:
            
            [[self player] play];
            
            break;
        case BabyPlayerNativeStateStopped:
            
            [self setupPlayer];
            
            break;
            
        default:
            break;
    }
    
}

-(void)pause {
    
    if ([self state] == BabyPlayerNativeStatePaused ||
        [self state] == BabyPlayerNativeStateStopped) return;
    
    [[self player] pause];
    
}

-(void)stop {
    
    if ([self state] != BabyPlayerNativeStateStopped) return;
    
    [self destroyPlayer];
    
}

#pragma mark - Player

-(void)setupPlayer {
    
    if (![self URL]) return;
    
    [self destroyPlayer];
    
    
    NSLog(@"bounds x is %f, y is %f, w is %f, h is %f", self.bounds.origin.x, self.bounds.origin.y, self.bounds.size.width, self.bounds.size.height);
    
    // 设置view
    self.playButton = [[UIImageView alloc]initWithImage:ImageNamed(@"baby_rcd_btn_play")];
    self.playButton.frame = CGRectMake( (self.bounds.size.width - kMediaPlayWH) / 2 ,  (self.bounds.size.height - kMediaPlayWH) / 2, kMediaPlayWH, kMediaPlayWH);
    self.playButton.hidden = YES;
    self.playButton.layer.zPosition = 1000;
    [self addSubview:self.playButton];
    
    self.mediaProgress = [[UIProgressView alloc]init];
    self.mediaProgress.frame = CGRectMake(0, self.bounds.size.height - 2, self.bounds.size.width, 2);
    self.mediaProgress.progressTintColor = UIColorFromRGB(BABYCOLOR_base_color);
    self.mediaProgress.trackTintColor = [UIColor grayColor];
    [self.mediaProgress setProgress:0.5];
    self.mediaProgress.layer.zPosition = 1000;
    [self addSubview:self.mediaProgress];
    
    self.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playMeida)];
    
    [self addGestureRecognizer:tap];
    
    
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[self URL]];
    
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndNone];
    [player setVolume:[self playerVolume]];
    [self setPlayer:player];
    
    [self addObservers];
    
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [playerLayer setFrame:[self bounds]];
    [[self layer] addSublayer:playerLayer];
    [self setPlayerLayer:playerLayer];
    
    [player play];
    
    [self layoutSubviews];
    
}

-(void)destroyPlayer {
    
    [self removeObservers];
    [self setPlayer:nil];
    [[self playerLayer] removeFromSuperlayer];
    [self.playButton removeFromSuperview];
    [self.mediaProgress removeFromSuperview];
    [self.mCircleProgress removeFromSuperview];
    [self setPlayerLayer:nil];
    [self setStateNotifyingDelegate:BabyPlayerNativeStateStopped];
    
}

#pragma mark - Player Notifications

-(void)playerFailed:(NSNotification *)notification {
    
    [self destroyPlayer];
    
    if ([[self delegate] respondsToSelector:@selector(videoPlayer:encounteredError:)])
        [[self delegate] videoPlayer:self encounteredError:[NSError errorWithDomain:@"BabyPlayerNative" code:1 userInfo:@{ NSLocalizedDescriptionKey : @"An unknown error occurred." }]];
    
}

-(void)playerPlayedToEnd:(NSNotification *)notification {
    
    switch ([self endAction]) {
        case BabyPlayerNativeEndActionStop:
            
            [self destroyPlayer];
            
            break;
        case BabyPlayerNativeEndActionLoop:
            
            [[[self player] currentItem] seekToTime:kCMTimeZero];
            
            break;
    }
    
}

#pragma mark - Observers

-(void)addObservers {
    
    [[self player] addObserver:self forKeyPath:@"rate" options:0 context:NULL];
    
    [[[self player] currentItem] addObserver:self forKeyPath:@"playbackBufferEmpty" options:0 context:NULL];
    [[[self player] currentItem] addObserver:self forKeyPath:@"status" options:0 context:NULL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:[[self player] currentItem]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerPlayedToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:[[self player] currentItem]];
    
}

-(void)removeObservers {
    
    [[self player] removeObserver:self forKeyPath:@"rate"];
    
    [[[self player] currentItem] removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [[[self player] currentItem] removeObserver:self forKeyPath:@"status"];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

#pragma mark - KVO

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    if (object == [self player]) {
        
        if ([keyPath isEqualToString:@"rate"]) {
            
            CGFloat rate = [[self player] rate];
            if (![self loaded]) {
                
                [self setStateNotifyingDelegate:BabyPlayerNativeStateLoading];
                
            } else if (rate == 1.0) {
                
                [self setStateNotifyingDelegate:BabyPlayerNativeStatePlaying];
                
            } else if (rate == 0.0) {
                
                if ([self bufferEmpty]) {
                    
                    [self setStateNotifyingDelegate:BabyPlayerNativeStateLoading];
                    
                } else {
                    
                    [self setStateNotifyingDelegate:BabyPlayerNativeStatePaused];
                    
                }
                
            }
            
        }
        
    } else if (object == [[self player] currentItem]) {
        
        if ([keyPath isEqualToString:@"status"]) {
            
            AVPlayerItemStatus status = [[[self player] currentItem] status];
            switch (status) {
                case AVPlayerItemStatusFailed:
                    
                    [self destroyPlayer];
                    
                    if ([[self delegate] respondsToSelector:@selector(videoPlayer:encounteredError:)])
                        [[self delegate] videoPlayer:self encounteredError:[[[self player] currentItem] error]];
                    
                    break;
                case AVPlayerItemStatusReadyToPlay:
                    
                    [self setLoaded:YES];
                    [self setStateNotifyingDelegate:BabyPlayerNativeStatePlaying];
                    self.playing = true;
                    break;
                case AVPlayerItemStatusUnknown:
                    break;
            }
            
        } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
            
            BOOL empty = [[[self player] currentItem] isPlaybackBufferEmpty];
            [self setBufferEmpty:empty];
            
        }
        
    }
    
}

#pragma mark - Getters & Setters

-(CGFloat)playerVolume {
    
    if ([self isMuted]) return 0.0;
    return 1.0;
    
}

-(void)setMuted:(BOOL)muted {
    
    _muted = muted;
    
    [[self player] setVolume:[self playerVolume]];
    
}

-(void)setURL:(NSURL *)URL {
    
    _URL = URL;
    
    [self destroyPlayer];
    
}

#pragma mark UIControll

- (void)refreshMediaControl
{
    CMTime durationCT = self.player.currentItem.asset.duration;
    NSTimeInterval duration = CMTimeGetSeconds(durationCT);
    CMTime positionCT = self.player.currentTime;
    NSTimeInterval position = CMTimeGetSeconds(positionCT);
    //    NSLog(@"refreshMediaControl progress -- %f", position / duration);
    //总时间大于10秒 则显示进度条
    //        if (duration > 10) {
    self.mediaProgress.hidden = NO;
    [self.mediaProgress setProgress:(position / duration)];
    //        } else
    //            self.mediaProgress.hidden = YES;
    if(self.playing)
        self.playButton.hidden = YES;
    else
        self.playButton.hidden = NO;
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(refreshMediaControl) object:nil];
    [self performSelector:@selector(refreshMediaControl) withObject:nil afterDelay:0.5];
}

- (void)playMeida
{
    NSLog(@"self.isPlaying is %d", self.playing);
    if (self.playing) {
        [self.player pause];
    } else {
        [self.player play];
    }
    
    
}

-(void)setState:(BabyPlayerNativeState)state {
    
    _state = state;
    
    switch (state) {
        case BabyPlayerNativeStatePaused:
        case BabyPlayerNativeStateStopped:
            self.playing = false;
            break;
        case BabyPlayerNativeStateLoading:
        case BabyPlayerNativeStatePlaying:
            self.playing = true;
            break;
        default:
            break;
    }
    
}

#pragma mark - Delegate

-(void)setStateNotifyingDelegate:(BabyPlayerNativeState)state {
    
    BabyPlayerNativeState previousState = [self state];
    [self setState:state];
    
    if (state != previousState) {
        
        if ([[self delegate] respondsToSelector:@selector(videoPlayer:changedState:)])
            [[self delegate] videoPlayer:self changedState:state];
        
    }
    
}

@end

