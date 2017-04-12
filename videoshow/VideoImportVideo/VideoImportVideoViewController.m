//
//  VideoImportVideoViewController.m
//  Babypai
//
//  Created by ning on 16/5/18.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoImportVideoViewController.h"

#import "MediaObject.h"
#import "BabyFileManager.h"
#import "SVProgressHUD.h"
#import <IJKMediaFramework/VideoEncoder.h>
#import "ThemeHelper.h"
#import "VideoPreviewViewController.h"
#import "UIButton+UIButtonImageWithLabel.h"
#import "ICGVideoTrimmerView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoImportVideoViewController () <ICGVideoTrimmerDelegate>

@property (assign, nonatomic) BOOL isPlaying;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) AVPlayerItem *playerItem;
@property (strong, nonatomic) AVPlayerLayer *playerLayer;
@property (strong, nonatomic) NSTimer *playbackTimeCheckerTimer;
@property (assign, nonatomic) CGFloat videoPlaybackPosition;

@property (strong, nonatomic) ICGVideoTrimmerView *trimmerView;
@property (strong, nonatomic) UIView *videoLayer;
@property (strong, nonatomic) UILabel *videoTime;
@property (strong, nonatomic) UIImageView *playImage;

@property (strong, nonatomic) AVAssetExportSession *exportSession;
@property (strong, nonatomic) AVAsset *asset;

@property (assign, nonatomic) CGFloat startTime;
@property (assign, nonatomic) CGFloat stopTime;

@property (assign, nonatomic) CGFloat videoWidth, videoHeight;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) MediaObject *mMediaObject;
@property (nonatomic, strong) MediaPart *mMediaPart;
/**
 * 公共文件
 */
@property (nonatomic, strong) NSString *mThemeCommonPath;

@property (nonatomic, assign) BOOL hasSavedDraft;

@end

@implementation VideoImportVideoViewController

- (NSString *)title
{
    return @"截取";
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    [self showBackItem];
    CGSize rightTexttSize = [@"完成" sizeWithAttributes:@{NSFontAttributeName: kFontSize(18)}];
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, rightTexttSize.width + 16, rightTexttSize.height)];
    rightButton.titleLabel.font = kFontSize(18);
    [rightButton addTarget:self action:@selector(pressNextButton) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"完成" titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"完成" titleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithCustomView:rightButton];
    
    self.navigationItem.rightBarButtonItem = item;
    
    self.asset = [AVAsset assetWithURL:_videoPath];
    self.mThemeCommonPath = [[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:THEME_VIDEO_COMMON];
    
    [self setupViews];
    [self setupPlayer];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;

    //[MobClick beginLogPageView:[self title]];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.player) {
        [self.player pause];
        [self.playerItem cancelPendingSeeks];
    }
    //[MobClick endLogPageView:[self title]];
    
}

- (void)setupViews
{
    self.view.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    _videoLayer = [[UIView alloc]init];
    _videoLayer.backgroundColor = [UIColor blackColor];
    
    UILabel *tipLable = [[UILabel alloc]init];
    tipLable.text = @"↓拖动选择你要剪裁的片段";
    tipLable.font = kFontSizeNormal;
    tipLable.textColor = UIColorFromRGB(BABYCOLOR_gray);
    tipLable.textAlignment = NSTextAlignmentCenter;
    
    _videoTime = [[UILabel alloc]init];
    _videoTime.text = @"10.0秒";
    _videoTime.font = kFontSizeBig;
    _videoTime.textColor = [UIColor whiteColor];
    _videoTime.textAlignment = NSTextAlignmentCenter;
    
    _playImage = [[UIImageView alloc]initWithImage:ImageNamed(@"baby_rcd_btn_play")];
    _playImage.hidden = YES;
    
    _trimmerView = [[ICGVideoTrimmerView alloc]initWithAsset:_asset];
    
    [self.view sd_addSubviews:@[_videoLayer, tipLable, _videoTime, _trimmerView, _playImage]];
    
    _videoLayer.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(SCREEN_WIDTH)
    .topSpaceToView(self.view, 30)
    .leftEqualToView(self.view);
    
    _videoTime.sd_layout
    .widthIs(100)
    .heightIs(36)
    .bottomEqualToView(self.view)
    .centerXEqualToView(self.view);
    
    _trimmerView.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(80)
    .leftEqualToView(self.view)
    .bottomSpaceToView(_videoTime, 4);
    
    tipLable.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(36)
    .bottomSpaceToView(_trimmerView, 0)
    .leftEqualToView(self.view);
    
    _playImage.sd_layout
    .widthIs(60)
    .heightIs(60)
    .centerXEqualToView(_videoLayer)
    .centerYEqualToView(_videoLayer);
    
}

- (void)setupPlayer
{
    
    AVAssetTrack *vT = nil;
    if ([[_asset tracksWithMediaType:AVMediaTypeVideo] count] != 0)
    {
        vT = [[_asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    if (vT != nil)
    {
        _videoWidth = vT.naturalSize.width;
        _videoHeight = vT.naturalSize.height;
    }
    
    DLogE(@"_videoWidth : %f, _videoHeight : %f", _videoWidth, _videoHeight);
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithAsset:self.asset];
    
    self.player = [AVPlayer playerWithPlayerItem:item];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.playerLayer.contentsGravity = AVLayerVideoGravityResizeAspect;
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    self.playerLayer.frame = self.videoLayer.bounds;
    
    [self.videoLayer.layer addSublayer:self.playerLayer];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnVideoLayer:)];
    [self.videoLayer addGestureRecognizer:tap];
    
    self.videoPlaybackPosition = 0;
    
    [self tapOnVideoLayer:tap];
    
    // set properties for trimmer view
    [self.trimmerView setThemeColor:UIColorFromRGB(BABYCOLOR_background_gray)];
    [self.trimmerView setAsset:self.asset];
    [self.trimmerView setShowsRulerView:YES];
    [self.trimmerView setTrackerColor:[UIColor whiteColor]];
    [self.trimmerView setDelegate:self];
    [self.trimmerView setMaxLength:10];
    [self.trimmerView setMinLength:3];
    
    // important: reset subviews
    [self.trimmerView resetSubviews];
}

- (void)pressNextButton
{
    NSLog(@"pressNextButton------");
    [self.player pause];
    _playImage.hidden = NO;
    if (_mMediaObject != nil) {
        if (!_hasSavedDraft)
            [_mMediaObject deleteObject];
        _mMediaObject = nil;
    }
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showProgress:0 status:@"生成视频中"];
    
    [self setOutputDirectory];
    [self startEncodeVideo];
}

- (void)setOutputDirectory
{
    int64_t date = [[NSDate date] timeIntervalSince1970]*1000*1000;
    int random = arc4random();
    if (random < 0) {
        random = -random;
    }
    _key = [NSString stringWithFormat:@"%lld_%d", date, random];
    DLog(@"key : %@", _key);
    
    NSString *tempPath = [BabyFileManager createVideoFolderIfNotExist:_key];
    DLog(@"tempPath : %@", tempPath);
    
    self.mMediaObject = [MediaObject initWithKey:_key path:tempPath];
    DLog(@"self.mMediaObject max : %d", self.mMediaObject.mMaxDuration);
    
    _mMediaPart = [_mMediaObject buildMediaPart:[_videoPath absoluteString] duration:(int)((_stopTime - _startTime) * 1000) type:MEDIA_PART_TYPE_IMPORT_VIDEO];
    
    _mMediaPart.startTime = (double)(_startTime * 1000);
    _mMediaPart.endTime = (double)(_stopTime * 1000);
    
    DLogE(@"startTime : %f, endTime : %f", _mMediaPart.startTime, _mMediaPart.endTime);
    DLogE(@"durtion : %d", _mMediaPart.duration);
    
}

- (void)startEncodeVideo
{
    __block VideoImportVideoViewController *blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 生成视频
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-ss"];
        [mutableArray addObject:[NSString stringWithFormat:@"%d", (int)_mMediaPart.startTime / 1000]];
        [mutableArray addObject:@"-t"];
        [mutableArray addObject:[NSString stringWithFormat:@"%d", (int)(_mMediaPart.endTime - _mMediaPart.startTime) / 1000]];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:_mMediaPart.tempPath];
        
        [mutableArray addObject:@"-filter_complex"];
        
        long rotation = [[BabyFileManager manager]degressFromVideoFileWithURL:_videoPath];
        
        int cX = 0;
        
        float videoAspectRatio = _videoWidth * 1.0 / _videoHeight;
        
        DLog(@"videoAspectRatio : %f", videoAspectRatio);
        
        NSString *filters = [[NSString alloc]init];
        filters = [filters stringByAppendingString:@"[0:v]"];
//        BOOL hasRotation = true;
//        switch (rotation) {
//            case 90:
//                filters = [filters stringByAppendingString:@"transpose=1[tmp];[tmp]"];
//                break;
//            case 270:
//                filters = [filters stringByAppendingString:@"transpose=2[tmp];[tmp]"];
//                break;
//            case 180:
//                filters = [filters stringByAppendingString:@"vflip[vflip];[vflip]hflip[tmp];[tmp]"];
//                break;
//            default:
//                hasRotation = false;
//                break;
//        }
        filters = [filters stringByAppendingString:@"scale='if(gt(a,1),480,-1)':'if(gt(a,1),-1,480)'"];
        
        if(_videoWidth != _videoHeight) {
            
            filters = [filters stringByAppendingString:@"[temp1];[0:v]"];
//            
            
            
            filters = [filters stringByAppendingString:@"boxblur=luma_radius=min(h\\,w)/20:luma_power=1:chroma_radius=min(cw\\,ch)/20:chroma_power=1[bg];[bg]crop=480:480:0:0[bg2];"];
            
            filters = [filters stringByAppendingString:@"[bg2][temp1]overlay="];
            
            cX = (int) ((480 - 480 / videoAspectRatio) / 2);
            
            switch (rotation) {
                case 90:
                case 270:
                    filters = [filters stringByAppendingString:[NSString stringWithFormat:@"%d:%d", cX, 0]];
                    break;
                case 180:
                case 0:
                    filters = [filters stringByAppendingString:[NSString stringWithFormat:@"%d:%d", 0, cX]];
                    break;
            }
            
            
            
        }
        DLogE(@"filters : %@", filters);
        
        [mutableArray addObject:filters];
        
        //去除旋转信息
//        if (hasRotation) {
//            [mutableArray addObject:@"-metadata:s:v"];
//            [mutableArray addObject:@"rotate=''"];
//        }
        
        // 裁剪时间 -ss是秒 -t也是秒
//        [mutableArray addObject:@"-ss"];
//        [mutableArray addObject:[[BabyFileManager manager]convertVideoCutTime:_mMediaPart.startTime]];
//        [mutableArray addObject:@"-t"];
//        [mutableArray addObject:[[BabyFileManager manager]convertVideoCutTime:ceil((_mMediaPart.endTime - _mMediaPart.startTime) / 1000.0)]];
        
        
        [mutableArray addObject:@"-c:a"];
        [mutableArray addObject:@"libfaac"];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c:v"];
        [mutableArray addObject:@"libx264"];
        [mutableArray addObject:@"-s"];
        [mutableArray addObject:@"480x480"];
        [mutableArray addObject:@"-t"];
        [mutableArray addObject:[NSString stringWithFormat:@"%d", [_mMediaPart getDuration] / 1000]];
        [mutableArray addObject:@"-pix_fmt"];
        [mutableArray addObject:@"yuv420p"];
        [mutableArray addObject:@"-r"];
        [mutableArray addObject:@"25"];
        
        [mutableArray addObject:_mMediaPart.mediaPath];
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            float progress = (double)timestamp / ([blockSelf.mMediaPart getDuration] * 1000);
            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, progress);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showProgress:progress status:@"生成视频中"];
                
            });
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [blockSelf mergeVideoFiles];
                
            });
            
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
    });
    
}

- (void)mergeVideoFiles
{
    __weak __typeof__(self) weakSelf = self;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString *concatPath = [BabyFileManager getVideoMergeFilePathString:weakSelf.mMediaObject.mOutputDirectory concatText:[self.mMediaObject getConcatYUV]];
        DLog(@"concatPath : %@", concatPath);
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-f"];
        [mutableArray addObject:@"concat"];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:concatPath];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c"];
        [mutableArray addObject:@"copy"];
        [mutableArray addObject:@"-absf"];
        [mutableArray addObject:@"aac_adtstoasc"];
        [mutableArray addObject:@"-movflags"];
        [mutableArray addObject:@"+faststart"];
        [mutableArray addObject:[weakSelf.mMediaObject getOutputTempVideoPath]];
        
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, (double)timestamp / ([weakSelf.mMediaObject getDuration] * 1000));
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                if (weakSelf.fromWhich==2) {
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                    if (weakSelf.onPublish) {
                        weakSelf.onPublish([weakSelf.mMediaObject getOutputTempVideoPath]);
                    }
                }
                else
                    [weakSelf pushVideoPreview];
                [SVProgressHUD dismiss];
                
            });
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
        
    });
    
}

- (void)pushVideoPreview
{
    VideoPreviewViewController *player = [[VideoPreviewViewController alloc]initWithMediaObject:self.mMediaObject];
    player.tag = _tag;
    player.tag_id = _tag_id;
    player.fromDraft = NO;
    player.outputHeight = 480;
    
    player.savedDraft = ^(BOOL saved) {
        _hasSavedDraft = saved;
    };
    
    player.onPublish = ^() {
        if (self.onPublish) {
            self.onPublish(@"");
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:player animated:YES];
}

#pragma mark - ICGVideoTrimmerDelegate

- (void)trimmerView:(ICGVideoTrimmerView *)trimmerView didChangeLeftPosition:(CGFloat)startTime rightPosition:(CGFloat)endTime
{
    if (startTime != self.startTime) {
        //then it moved the left position, we should rearrange the bar
        [self seekVideoToPos:startTime];
    }
    self.startTime = startTime;
    self.stopTime = endTime;
    
    _videoTime.text = [NSString stringWithFormat:@"%.01f秒", (endTime - startTime)];
}

- (void)tapOnVideoLayer:(UITapGestureRecognizer *)tap
{
    if (self.isPlaying) {
        [self.player pause];
        [self stopPlaybackTimeChecker];
        _playImage.hidden = NO;
    }else {
        [self.player play];
        [self startPlaybackTimeChecker];
        _playImage.hidden = YES;
    }
    self.isPlaying = !self.isPlaying;
    [self.trimmerView hideTracker:!self.isPlaying];
}

- (void)startPlaybackTimeChecker
{
    [self stopPlaybackTimeChecker];
    
    self.playbackTimeCheckerTimer = [NSTimer scheduledTimerWithTimeInterval:0.1f target:self selector:@selector(onPlaybackTimeCheckerTimer) userInfo:nil repeats:YES];
}

- (void)stopPlaybackTimeChecker
{
    if (self.playbackTimeCheckerTimer) {
        [self.playbackTimeCheckerTimer invalidate];
        self.playbackTimeCheckerTimer = nil;
    }
}

#pragma mark - PlaybackTimeCheckerTimer

- (void)onPlaybackTimeCheckerTimer
{
    self.videoPlaybackPosition = CMTimeGetSeconds([self.player currentTime]);
    
    [self.trimmerView seekToTime:CMTimeGetSeconds([self.player currentTime])];
    
    if (self.videoPlaybackPosition >= self.stopTime) {
        self.videoPlaybackPosition = self.startTime;
        [self seekVideoToPos: self.startTime];
        [self.trimmerView seekToTime:self.startTime];
    }
}

- (void)seekVideoToPos:(CGFloat)pos
{
    self.videoPlaybackPosition = pos;
    CMTime time = CMTimeMakeWithSeconds(self.videoPlaybackPosition, self.player.currentTime.timescale);
    [self.player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
}

@end
