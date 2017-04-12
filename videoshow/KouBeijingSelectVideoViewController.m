//
//  KouBeijingSelectVideoViewController.m
//  videoshow
//
//  Created by Xinle on 2017/4/12.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "KouBeijingSelectVideoViewController.h"
#import "MacroDefinition.h"
#import <IJKMediaFramework/IJKMediaPlayback.h>
#import <IJKMediaFramework/IJKFFMoviePlayerController.h>

#import "BabyMediaControl.h"
#import "VideoImportVideoViewController.h"
#import "CellTheme.h"
#import "BabyFileManager.h"
#import "ThemeHelper.h"
#import "StringUtils.h"
#import "MenuHrizontal.h"
#import "SVProgressHUD.h"
#import "ImageUtils.h"
#import "UIButton+UIButtonImageWithLabel.h"
#import "BabyUploadEntity.h"
#import <IJKMediaFramework/VideoEncoder.h>
#import "VideoPublishViewController.h"
#import "ThemeStoreViewController.h"
#import "BabyNavigationController.h"
#import "UIView+SDAutoLayout.h"
#import "HechengViewController.h"
@interface KouBeijingSelectVideoViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property(atomic, retain) id<IJKMediaPlayback> player;
@property(nonatomic, strong) BabyMediaControl *mediaControl;
@end

@implementation KouBeijingSelectVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self showBackItem];
    self.view.backgroundColor = [UIColor whiteColor];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"]] withFilters:@[] withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH);
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    [self.player.view setBackgroundColor:[UIColor whiteColor]];
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    
    
    [self.player prepareToPlay];
    
    
    [self installMovieNotificationObservers];
    [self.player playWithURLString:[[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"] withFilters:@[]];
    
    self.mediaControl = [[BabyMediaControl alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH)];
    [self.mediaControl showLoading:NO];
    [self.view addSubview:self.mediaControl];
    
    self.mediaControl.delegatePlayer = self.player;
    [self.mediaControl hideAndRefresh];
    
    
    UIButton * selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [selectBtn setFrame:CGRectMake(SCREEN_WIDTH/2-40, SCREEN_HEIGHT-64-60, 80, 35)];
    selectBtn.backgroundColor = [UIColor colorWithRed:254/255.f green:51/255.f blue:122/255.f alpha:1];
    [selectBtn setTitle:@"选择前景" forState:UIControlStateNormal];
    selectBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [selectBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.view addSubview:selectBtn];
    [selectBtn addTarget:self action:@selector(pressVideoImportButton) forControlEvents:UIControlEventTouchUpInside];
    // Do any additional setup after loading the view.
}
- (void)pressVideoImportButton
{
    //    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:9 delegate:self];
    //    // 设置是否可以选择视频/图片
    //    imagePickerVc.allowPickingVideo = YES;
    //    imagePickerVc.allowPickingImage = NO;
    //
    //    [self presentViewController:imagePickerVc animated:YES completion:nil];
    
    //UIImagePickerController相册选择视频
    
    [self.player pause];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    //资源类型为视频库
    
    NSString *requiredMediaType1 = (NSString *)kUTTypeMovie;
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    //UIImagePickerControllerSourceTypeSavedPhotosAlbum
    
    NSArray *arrMediaTypes=[NSArray arrayWithObjects:requiredMediaType1,nil];
    
    [picker setMediaTypes: arrMediaTypes];
    
    picker.delegate = (id)self;
    
    [[picker navigationBar] setBarTintColor:[AppAppearance sharedAppearance].mainColor];
    [[picker navigationBar] setTintColor:[UIColor whiteColor]];
    [[picker navigationBar] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    [self presentViewController:picker animated:YES completion:nil];
    
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:@"public.movie"])
    {
        NSURL *videoURL = [info objectForKey:UIImagePickerControllerMediaURL];
        NSLog(@"found a video ： %@", videoURL);
        [self pushToVideoImport:videoURL];
    }
}
- (void)pushToVideoImport:(NSURL *)filePath
{
    __weak __typeof__(self) weakSelf = self;
    VideoImportVideoViewController *videoImportVc = [[VideoImportVideoViewController alloc]init];
    videoImportVc.tag = @"0";
    videoImportVc.tag_id = 0;
    videoImportVc.fromWhich = 2;
    videoImportVc.videoPath = filePath;
    videoImportVc.onPublish = ^(NSString * filePath) {
        [weakSelf mergeVideoWithFrontVideoUrl:filePath];
    };
    [self.navigationController pushViewController:videoImportVc animated:YES];
}

-(void)mergeVideoWithFrontVideoUrl:(NSString *)frontUrl
{
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showProgress:0 status:@"生成视频中"];
    
    __weak __typeof__(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 生成视频
        
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:[[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"]];
        [mutableArray addObject:@"-i"];
        
        
        
        [mutableArray addObject:frontUrl];
        
        [mutableArray addObject:@"-filter_complex"];
        NSString *filter = @"[1:v]colorkey=0xffffff:0.45:0.2[keyed];[0:v][keyed]overlay[out]";
        [mutableArray addObject:filter];
        
        [mutableArray addObject:@"-map"];
        [mutableArray addObject:@"[out]"];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        
        NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
        
        NSString *tempPath = [folderPath stringByAppendingPathComponent:@"55555555555.mp4"];
        
        [mutableArray addObject:tempPath];
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            
//            float progress = (double)timestamp / (videoTime * 1000 * 1000);
//            DLog(@"执行中：size = %ld, timestamp = %ld -> 执行进度 ：%.2f", size, timestamp, progress);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
                [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
                [SVProgressHUD showProgress:0.5 status:@"生成视频中"];
                
            });
        };
        
        OnEncoderCompletionBlock block = ^(int ret, NSString* retString) {
            DLog(@"执行完毕：ret = %d, retString : %@", ret, retString);
            //通知主线程刷新
            dispatch_async(dispatch_get_main_queue(), ^{
                //回调或者说是通知主线程刷新，
                
                HechengViewController * h = [[HechengViewController alloc] init];
                h.path = tempPath;
                [self.navigationController pushViewController:h animated:YES];
                
                [SVProgressHUD dismiss];
                
            });
            
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
    });
    
    
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
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;
            
        case IJKMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonUserExited: %d\n", reason);
            [self.player playWithURLString:[[NSBundle mainBundle] pathForResource:@"test_264" ofType:@"mp4"] withFilters:@[]];
            break;
            
        case IJKMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: IJKMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;
            
        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
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
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePlaying: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStatePaused: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateInterrupted: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case IJKMPMoviePlaybackStateSeekingForward:
        case IJKMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"IJKMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}


#pragma mark Install Movie Notifications

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
- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started
    
    IJKMPMovieLoadState loadState = _player.loadState;
    
    if ((loadState & IJKMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & IJKMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: IJKMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
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


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.navigationController.navigationBar.barTintColor = [AppAppearance sharedAppearance].mainColor;
    
    //[MobClick beginLogPageView:[self title]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
