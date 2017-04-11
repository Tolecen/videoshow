//
//  VideoPublishViewController.m
//  Babypai
//
//  Created by ning on 16/5/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoPublishViewController.h"
#import "BabyUploadEntity.h"
#import "UIButton+UIButtonImageWithLabel.h"
#import "UIView+SDAutoLayout.h"
#import "BabyFileManager.h"
//#import "ALDBlurImageProcessor.h"
//#import "HPGrowingTextView.h"
#import "Users.h"
#import "StringUtils.h"
#import "SVProgressHUD.h"
#import "PostMessage.h"
#import "Boards.h"
//#import "PublishUserViewController.h"
#import "BabyNavigationController.h"
//#import "BoardsViewController.h"
#import "BabyPinUpload.h"


//#import "PublishLocationViewController.h"
//#import "PublishTitlePageViewController.h"

#define LocationTimeout 3  //   定位超时时间，可修改，最小2s
#define MAX_LIMIT_NUMS 140

@interface VideoPublishViewController () <UIActionSheetDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isDraft;
@property (nonatomic, strong) UIButton *rightButton;

@property (nonatomic, strong) UIImageView *topImage;
@property (nonatomic, strong) UIImageView *smallImageInScroll;
@property (nonatomic, strong) NSString *mCoverPath;

//@property(nonatomic, strong) HPGrowingTextView *textView;
@property(nonatomic, strong) UILabel *textViewNum;

@property (nonatomic, strong) UIButton *tagButton, *atButton, *locationButton, *privateButton, *addBoardButton;
@property (strong, nonatomic) UIButton *closeButton;

@property (nonatomic, strong) UILabel *addBoardTip;

@property (nonatomic, strong) NSString *locationText;

@property (nonatomic, assign) long publish_board_id;
@property (nonatomic, strong) NSString *publish_board_text;
@property (nonatomic, strong) NSString *publish_raw_text;

@property (nonatomic, assign) BOOL bool_private;
@property (nonatomic, assign) BOOL bool_location;

@property (nonatomic, strong) NSMutableArray *friends;
@property (nonatomic, strong) NSMutableArray *atUsersArray;
@property (nonatomic, strong) NSString *atUsers;

@property (nonatomic, assign) double mLatitude;
@property (nonatomic, assign) double mLongitude;
@property (nonatomic, assign) int mProvinceCode;
@property (nonatomic, strong) NSString *mProvince;
@property (nonatomic, assign) int mCityCode;
@property (nonatomic, strong) NSString *mCity;
@property (nonatomic, assign) int mDistrictCode;
@property (nonatomic, strong) NSString *mDistrict;
@property (nonatomic, strong) NSString *mStreet;
@property (nonatomic, strong) NSString *mAddrStr;
@property (nonatomic, strong) NSString *mLocationDescribe;
@property (nonatomic, strong) NSMutableArray *mPoi;
@property (nonatomic, strong) NSString *poi;

@property (nonatomic, strong) UIActionSheet *locationSheet;

//@property (nonatomic, strong) AMapLocationManager *locationManager;

@end

@implementation VideoPublishViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    UIView *colorBack = [[UIView alloc] init];
    [colorBack setBackgroundColor:RGB(244.0f, 48.0f, 125.0f)];
    [self.view addSubview:colorBack];
    colorBack.sd_layout.xIs(0).yIs(0).widthIs(self.view.width).heightIs(64);

    
    
    
    UIButton *publishButtonSave = [[UIButton alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - NavigationBar_HEIGHT), SCREEN_WIDTH, NavigationBar_HEIGHT)];
    
    publishButtonSave.titleLabel.font = kFontSize(18);
    [publishButtonSave addTarget:self action:@selector(pressPublishButton) forControlEvents:UIControlEventTouchUpInside];
    [publishButtonSave setBackgroundImage:ImageNamed(@"savepublish") forState:UIControlStateNormal];
    [self.view addSubview:publishButtonSave];
    
    publishButtonSave.sd_layout.centerXIs(SCREEN_WIDTH/4.0f).centerYIs(self.view.frame.size.height - 51*SCREEN_FACTORY).widthIs(51.0f*SCREEN_FACTORY).heightIs(51.0f*SCREEN_FACTORY);
    
    [publishButtonSave setBackgroundColor:[UIColor clearColor]];
    UILabel *labelSave = [[UILabel alloc] init];
    labelSave.textAlignment = 1;
    [labelSave setText:@"保存到本地"];
    [self.view addSubview:labelSave];
    
    
    labelSave.sd_layout.centerXIs(SCREEN_WIDTH/4.0f).topSpaceToView(publishButtonSave,-5.0f).widthIs(100).heightIs(30);
    
    
    NSLog(@"SCREEN_WIDTH=%f",SCREEN_WIDTH/4.0f);
    
    
    UIButton *publishButtonShare = [[UIButton alloc]initWithFrame:CGRectMake(0, (SCREEN_HEIGHT - NavigationBar_HEIGHT), SCREEN_WIDTH, NavigationBar_HEIGHT)];
    
    publishButtonShare.titleLabel.font = kFontSize(18);
    [publishButtonShare addTarget:self action:@selector(savedButton) forControlEvents:UIControlEventTouchUpInside];
    [publishButtonShare setBackgroundImage:ImageNamed(@"sharepublish") forState:UIControlStateNormal];
    [self.view addSubview:publishButtonShare];
    
    
    publishButtonShare.sd_layout.centerXIs(SCREEN_WIDTH*0.75f).centerYIs(self.view.frame.size.height - 51*SCREEN_FACTORY).widthIs(51.0f*SCREEN_FACTORY).heightIs(SCREEN_FACTORY*51.0f);
    [publishButtonShare setBackgroundColor:[UIColor clearColor]];
    
    
    
    UILabel *labelShare = [[UILabel alloc] init];
    labelShare.textAlignment = 1;
    [labelShare setText:@"分 享"];
    [self.view addSubview:labelShare];
    
    
    labelShare.sd_layout.leftEqualToView(publishButtonShare).rightEqualToView(publishButtonShare).topSpaceToView(publishButtonShare,-5.0f).heightIs(30);
    

    
    

    CGSize leftTexttSize = [@"返回" sizeWithAttributes:@{NSFontAttributeName: kFontSize(18)}];
    UIButton *backButton = [[UIButton alloc]initWithFrame:CGRectMake(4, (NavigationBar_HEIGHT - leftTexttSize.height) / 2+3, leftTexttSize.width + 32, leftTexttSize.height + 4)];
    backButton.titleLabel.font = kFontSize(18);
    [backButton addTarget:self action:@selector(pressBackButton) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[UIImage imageNamed:@"baby_icn_back"] withTitle:@"返回" titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    backButton.layer.zPosition = 1000;
    [self.view addSubview:backButton];
    
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 30, NavigationBar_HEIGHT / 2 - 15+3, 60, 30)];
    title.textColor = [UIColor whiteColor];
    title.font = kFontSize(20);
    title.textAlignment = NSTextAlignmentCenter;
    title.text = @"预览";
    title.layer.zPosition = 1000;
    [self.view addSubview:title];
    

    NSString *mVideoPath = self.mMediaObject.mOutputVideoPath;
    
    NSURL *urlMovie = [NSURL URLWithString:[[[BabyFileManager manager] themeDir] stringByAppendingString:[mVideoPath lastPathComponent]]];
    
    NSLog(@"urlMovie=%@",urlMovie);
    
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];

    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:urlMovie withFilters:self.videoFilter withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = CGRectMake(0, NavigationBar_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH);
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;

    [self.player.view setBackgroundColor:[UIColor whiteColor]];
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    
    
    [self.player prepareToPlay];
    
    
    [self initData];
    
    
    

    [self installMovieNotificationObservers];


}

- (void)savedButton
{
    NSString *mVideoPath = self.mMediaObject.mOutputVideoPath;

    NSURL *urlMovie = [NSURL URLWithString:[[[BabyFileManager manager] themeDir] stringByAppendingString:[mVideoPath lastPathComponent]]];
    
    NSLog(@"urlMovie=%@",urlMovie);
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:urlMovie
                                completionBlock:^(NSURL *assetURL, NSError *error) {
                                    if (error) {
                                        NSLog(@"Save video fail:%@",error);
                                    } else {
                                        NSLog(@"Save video succeed.");
                                    }
                                }];
}

-(void)initNavibar
{
    UIView *colorBack = [[UIView alloc] init];
    [colorBack setBackgroundColor:RGB(244.0f, 48.0f, 125.0f)];
    [self.view addSubview:colorBack];
    colorBack.sd_layout.xIs(0).yIs(0).widthIs(self.view.width).heightIs(64.0f);
    
    
    //关闭
    self.closeButton = [[UIButton alloc] init];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateNormal];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateDisabled];
    //    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateSelected];
    //    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.layer.zPosition = 1001;
    [self.view addSubview:_closeButton];
    
    
    _closeButton.sd_layout
    .widthIs(40)
    .heightIs(40)
    .topSpaceToView(self.view, 8)
    .leftSpaceToView(self.view, 5);
    

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
            [self.player playWithURLString:_mVideoTempPath withFilters:self.videoFilter];
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


-(void)pressCloseButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)initUserInfo
{
    [super initUserInfo];
    if (_publish_board_id == 0) {
        [self getUserLastBoard];
    }
    
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = YES;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    //    [UIView animateWithDuration:1.4 animations:^{
    //        self.navigationController.navigationBar.hidden = YES;
    //    } completion:^(BOOL finished) {
    //
    //        self.navigationController.navigationBar.hidden = YES;
    //
    //    }];
    
    _privateButton.selected = _bool_private;
    
    [self updateLocationButton];
    [self updateRightButton];
    [self updateAddBoardButton];
    [self updateTitlePage];
    
    
    [self.player playWithURLString:_mVideoTempPath withFilters:self.videoFilter];

//    [MobClick beginLogPageView:@"视频发布页面"];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self.player shutdown];

//    _locationManager = [[AMapLocationManager alloc] init];
//    [_locationManager setDelegate:self];
//    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
//    [_locationManager setPausesLocationUpdatesAutomatically:NO];
//    //    [_locationManager setAllowsBackgroundLocationUpdates:YES];
//    [_locationManager setLocationTimeout:LocationTimeout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    //    if (_fromDraft) {
    //        [self saveDraft:1];
    //    }
    
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.hidden = NO;
//    [MobClick endLogPageView:@"视频发布页面"];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
//    [self.locationManager stopUpdatingLocation];
//    [self.locationManager setDelegate:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)initData
{
//    _friends = [[NSMutableArray alloc]init];
//    _atUsersArray = [[NSMutableArray alloc]init];
//    _locationText = @"";
//    
//    _mCoverPath = _uploadEntity.file_image_path;
//    if ([StringUtils isEmpty:_mCoverPath]) {
//        _mCoverPath = _uploadEntity.file_image_original;
//    }
//    
//    _bool_private = [_uploadEntity.is_private intValue] > 0 ? YES : NO;
//    _publish_board_id = [_uploadEntity.board_id longValue];
//    _publish_board_text = _uploadEntity.board_name;
//    
//    _publish_raw_text = _uploadEntity.raw_text;
    
}

-(void)initNaviBar
{
    UIView *colorBack = [[UIView alloc] init];
    [colorBack setBackgroundColor:RGB(244.0f, 48.0f, 125.0f)];
    [self.view addSubview:colorBack];
    colorBack.sd_layout.xIs(0).yIs(0).widthIs(self.view.width).heightIs(50.0f);
    
    
    //关闭
    self.closeButton = [[UIButton alloc] init];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateNormal];
    [_closeButton setImage:ImageNamed(@"baby_icn_back") forState:UIControlStateDisabled];
    //    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateSelected];
    //    [_closeButton setImage:ImageNamed(@"record_cancel_press") forState:UIControlStateHighlighted];
    [_closeButton addTarget:self action:@selector(pressCloseButton) forControlEvents:UIControlEventTouchUpInside];
    _closeButton.layer.zPosition = 1001;
    [self.view addSubview:_closeButton];
    
    
    _closeButton.sd_layout
    .widthIs(40)
    .heightIs(40)
    .topSpaceToView(self.view, 5)
    .leftSpaceToView(self.view, 5);
    
    
    
    CGSize rightTexttSize = [@"下一步" sizeWithAttributes:@{NSFontAttributeName: kFontSize(18)}];
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(colorBack.frame.size.width-85.0f, 15.0f, rightTexttSize.width + 16, rightTexttSize.height)];
    rightButton.titleLabel.font = kFontSize(18);
    [rightButton addTarget:self action:@selector(pressNextButton) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"下一步" titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"下一步" titleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [colorBack addSubview:rightButton];
    
    
}

- (void)getUserLastBoard
{
    DataCompletionBlock completionBlock = ^(NSDictionary *data, NSString *errorString){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (data != nil) {
            Boards *boards = [Boards mj_objectWithKeyValues:data];
            if (boards.info != nil && boards.info.count > 0) {
                Board *board = [boards.info objectAtIndex:0];
                _publish_board_id = board.board_id;
                _publish_board_text = board.title;
                [self updateAddBoardButton];
            }
        }
    };
    
    
    BabyDataSource *souce = [BabyDataSource dataSource];
    
    NSString *fields = [NSString stringWithFormat:@"{\"boardId\":\"%ld\",\"uid\":\"%ld\"}", _publish_board_id, [self loginUserId]];
    [souce getData:USER_BOARD_LAST_PUBLISH parameters:fields completion:completionBlock];
}

- (void)updateTitlePage
{
    NSString *file_image_path = [[[BabyFileManager manager]getCurrentDocumentPath] stringByAppendingPathComponent:_uploadEntity.file_image_path];
    
    NSString *file_image_original = [[[BabyFileManager manager]getCurrentDocumentPath] stringByAppendingPathComponent:_uploadEntity.file_image_original];
    
    
    if (_uploadEntity.file_image_path != nil && [[Utils utils] isFileExists:file_image_path]) {
        _topImage.image = [UIImage imageWithContentsOfFile:file_image_path];
        _smallImageInScroll.image = [UIImage imageWithContentsOfFile:file_image_path];
    } else if (_uploadEntity.file_image_original != nil && [[Utils utils] isFileExists:file_image_original]) {
        _topImage.image = [UIImage imageWithContentsOfFile:file_image_original];
        _smallImageInScroll.image = [UIImage imageWithContentsOfFile:file_image_original];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
//        ALDBlurImageProcessor *_blurImageProcessor = [[ALDBlurImageProcessor alloc] initWithImage: _topImage.image];
//        [_blurImageProcessor asyncBlurWithRadius: 5
//                                      iterations: 11
//                                    successBlock: ^( UIImage *blurredImage) {
//                                        _topImage.image = blurredImage;
//                                    }
//                                      errorBlock: ^( NSNumber *errorCode ) {
//                                          DLog( @"Error code: %d", [errorCode intValue] );
//                                      }];
    }];
    
    
}

- (void)updateRightButton
{
    _isDraft = [_uploadEntity.is_draft intValue] == 1 ? YES : NO;
    NSString *rightText;
    if (_isDraft) {
        if (self.savedDraft) {
            self.savedDraft(YES);
        }
        rightText = @"已保存";
    } else {
        rightText = @"草稿箱";
        if (self.savedDraft) {
            self.savedDraft(NO);
        }
    }
    if (_rightButton) {
        [_rightButton removeFromSuperview];
    }
    CGSize rightTexttSize = [rightText sizeWithAttributes:@{NSFontAttributeName: kFontSize(18)}];
    _rightButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - rightTexttSize.width - 32, (NavigationBar_HEIGHT - rightTexttSize.height) / 2, rightTexttSize.width + 32, rightTexttSize.height + 4)];
    _rightButton.titleLabel.font = kFontSize(18);
    _rightButton.hidden = YES;
    [_rightButton addTarget:self action:@selector(pressDraftButton) forControlEvents:UIControlEventTouchUpInside];
    
    if (_isDraft) {
        [_rightButton setImage:[UIImage imageNamed:@""] withTitle:rightText titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@""] withTitle:rightText titleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _rightButton.enabled = NO;
    } else {
        [_rightButton setImage:[UIImage imageNamed:@"btn_save_draft_a"] withTitle:rightText titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_rightButton setImage:[UIImage imageNamed:@"btn_save_draft_b"] withTitle:rightText titleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
        _rightButton.enabled = YES;
    }
    _rightButton.layer.zPosition = 1000;
    [self.view addSubview:_rightButton];
    
    
    
}

- (void)updateLocationButton
{
    CGRect locationFrame = _locationButton.frame;
    
    if ([StringUtils isEmpty:_locationText]) {
        locationFrame.size.width = 30;
        _locationButton.titleLabel.text = nil;
        [_locationButton setImage:ImageNamed(@"ic_location_nor") forState:UIControlStateNormal];
        [_locationButton setImage:ImageNamed(@"ic_location_nor") forState:UIControlStateHighlighted];
        [_locationButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
        [_locationButton setTitleColor:[UIColor clearColor] forState:UIControlStateHighlighted];
        [_locationButton.imageView setContentMode:UIViewContentModeScaleToFill];
        [_locationButton setImageEdgeInsets:UIEdgeInsetsMake(6, 6, 6, 6)];
        
    } else {
        NSString *mLocationText = [NSString stringWithFormat:@" %@",_locationText];
        CGSize locationTexttSize = [mLocationText sizeWithAttributes:@{NSFontAttributeName: kFontSizeNormal}];
        
        locationFrame.size.width = MIN((SCREEN_WIDTH - 100 - 120), locationTexttSize.width + 32);
        
        [_locationButton setImage:[UIImage imageNamed:@"ic_location"] withTitle:mLocationText titleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateNormal];
        [_locationButton setImage:[UIImage imageNamed:@"ic_location"] withTitle:mLocationText titleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateHighlighted];
        [_locationButton setTitleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateNormal];
        [_locationButton setTitleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateHighlighted];
    }
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    _locationButton.frame = locationFrame;
    
    // commit animations
    [UIView commitAnimations];
    
    
}

- (void)updateAddBoardButton
{
    if (_addBoardButton) {
        [_addBoardButton removeFromSuperview];
    }
    
    CGFloat addBoardTipTop = CGRectGetMinY(_addBoardTip.frame);
    
    NSString *boardText = @"选择影集";
    if (_publish_board_id > 0) {
        boardText = _publish_board_text;
    }
    
    
    CGSize boardTexttSize = [boardText sizeWithAttributes:@{NSFontAttributeName: kFontSizeNormal}];
    _addBoardButton = [[UIButton alloc]initWithFrame:CGRectMake(SCREEN_WIDTH - boardTexttSize.width - 42, addBoardTipTop, boardTexttSize.width + 32, 48)];
    _addBoardButton.titleLabel.font = kFontSizeNormal;
    [_addBoardButton addTarget:self action:@selector(pressAddBoardButton) forControlEvents:UIControlEventTouchUpInside];
    
    [_addBoardButton setImageRight:[UIImage imageNamed:@"baby_icn_next_gray"] withTitle:boardText titleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateNormal];
    [_addBoardButton setImageRight:[UIImage imageNamed:@"baby_icn_next_gray"] withTitle:boardText titleColor:UIColorFromRGB(BABYCOLOR_main_text) forState:UIControlStateHighlighted];
    _addBoardButton.layer.zPosition = 1000;
    [_scrollView addSubview:_addBoardButton];
}

- (void)pressBackButton
{
    DLog(@"pressBackButton");
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)pressTagButton
{
//    DLog(@"pressTagButton");
//    [StringUtils updateTextViewTextInsertedString:self.textView withText:@"# #" isTag:YES];
}

- (void)pressAtButton
{
//    DLog(@"pressAtButton");
//    
//    PublishUserViewController *publishUser = [[PublishUserViewController alloc]init];
//    publishUser.userSelected = ^(NSMutableArray *users) {
//        DLog(@"users %@", users);
//        [_friends addObjectsFromArray:users];
//        DLog(@"_friends %@", _friends);
//        [self updateAtUsers:users];
//    };
//    
//    
//    BabyNavigationController *publishNav = [[BabyNavigationController alloc]initWithRootViewController:publishUser];
//    
//    [self presentViewController:publishNav animated:YES completion:nil];
}

- (void)pressLocationButton
{
    DLog(@"pressLocationButton");
    
    if (self.bool_location) {
        _locationSheet = [[UIActionSheet alloc]initWithTitle:@"位置信息" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改位置", @"删除位置", nil];
        [_locationSheet showInView:self.view];
    } else {
        [SVProgressHUD showWithStatus:@"正在获取位置"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        [self startLocation];
    }
}

- (void)startLocation
{
//    __weak VideoPublishViewController *wSelf = self;
//    AMapLocatingCompletionBlock completionBlock = ^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error)
//    {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [SVProgressHUD dismiss];
//        });
//        if (error)
//        {
//            NSLog(@"locError:{%ld - %@};", (long)error.code, error.localizedDescription);
            
            
//            [SVProgressHUD showErrorWithStatus:@"无法获取您的位置信息~"];
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                [SVProgressHUD dismiss];
//            });
//            
//            if (error.code == AMapLocationErrorLocateFailed)
//            {
//                return;
//            }
//        }
//        
//        if (location)
//        {
//            _mProvinceCode = 0;
//            _mCityCode = [regeocode.citycode intValue];
//            _mDistrictCode = [regeocode.adcode intValue];
//            _mProvince = regeocode.province;
//            _mCity = regeocode.city;
//            _mDistrict = regeocode.district;
//            _poi = regeocode.POIName;
//            
//            _locationText = regeocode.POIName;
//            _bool_location = YES;
//        }
//    };
    
//    [_locationManager requestLocationWithReGeocode:YES completionBlock:completionBlock];
      [SVProgressHUD dismiss];
      [self updateLocationButton];

}


- (void)pressDraftButton
{
    DLog(@"pressDraftButton");
    __block VideoPublishViewController *blockSelf = self;
    _uploadEntity.is_draft = [NSNumber numberWithInt:1];
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        [blockSelf updateRightButton];
    }];
    
}

- (void)pressPrivateButton
{
    DLog(@"pressPrivateButton");
    _bool_private = !_bool_private;
    _privateButton.selected = _bool_private;
    if (_bool_private) {
        [SVProgressHUD showErrorWithStatus:@"设置为隐私后，上传成功后不会分享给其他人啦~"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
}

- (void)pressAddBoardButton
{
    DLog(@"pressAddBoardButton");
    
//    BoardsViewController *boardsVC = [[BoardsViewController alloc]init];
//    boardsVC.user_id = [self loginUserId];
//    boardsVC.boardType = BOARDS_TYPE_SELECT;
//    boardsVC.onBoardSelect = ^(Board *board) {
//        DLog(@"board %@", board.title);
//        _publish_board_id = board.board_id;
//        _publish_board_text = board.title;
//        [self updateAddBoardButton];
//    };
//    [self.navigationController pushViewController:boardsVC animated:YES];
}

- (void)pressCoverButton
{
//    DLog(@"pressCoverButton");
//    PublishTitlePageViewController *titleVC = [[PublishTitlePageViewController alloc]init];
//    titleVC.videoPath = [[[BabyFileManager manager]getCurrentDocumentPath] stringByAppendingPathComponent:_uploadEntity.file_video_path];
//    titleVC.imagePath = [[[BabyFileManager manager]getCurrentDocumentPath] stringByAppendingPathComponent:_uploadEntity.file_image_path];
//    titleVC.titlePageSelected = ^(UIImage *image) {
//        [[BabyFileManager manager]saveUIImageToPath:[[[BabyFileManager manager]getCurrentDocumentPath] stringByAppendingPathComponent:_uploadEntity.file_image_path] withImage:image];
//    };
//    
//    BabyNavigationController *titleNav = [[BabyNavigationController alloc]initWithRootViewController:titleVC];
//    
//    [self presentViewController:titleNav animated:YES completion:nil];
}

- (void)pressPublishButton
{
    DLog(@"pressPublishButton");
    
    if (_publish_board_id == 0) {
        [SVProgressHUD showErrorWithStatus:@"请选择一个影集~"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
        return;
    }
    [self saveDraft:0];
    
}

- (void)saveDraft:(int)is_draft
{
//    [self updateAtAllUsers];
//    _publish_raw_text = self.textView.text;
//    
//    _uploadEntity.file_image_path = _mCoverPath;
//    _uploadEntity.file_time = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
//    _uploadEntity.board_id = [NSNumber numberWithLong:_publish_board_id];
//    _uploadEntity.board_name = _publish_board_text;
//    _uploadEntity.raw_text = _publish_raw_text;
//    _uploadEntity.at_uid = _atUsers;
//    _uploadEntity.is_private = _bool_private ? [NSNumber numberWithInt:1] : [NSNumber numberWithInt:0];
//    _uploadEntity.share_qq = [NSNumber numberWithInt:0];
//    _uploadEntity.share_wb = [NSNumber numberWithInt:0];
//    _uploadEntity.share_wx = [NSNumber numberWithInt:0];
//    _uploadEntity.is_draft = [NSNumber numberWithInt:is_draft];
//    
//    if (_bool_location) {
//        _uploadEntity.province_id = [NSNumber numberWithInt:_mProvinceCode];
//        _uploadEntity.city_id = [NSNumber numberWithInt:_mCityCode];
//        _uploadEntity.area_id = [NSNumber numberWithInt:_mDistrictCode];
//        _uploadEntity.province = _mProvince;
//        _uploadEntity.city = _mCity;
//        _uploadEntity.area = _mDistrict;
//        _uploadEntity.addr = _poi;
//        _uploadEntity.longitude = [NSNumber numberWithInt:_mLongitude];
//        _uploadEntity.latitude = [NSNumber numberWithInt:_mLatitude];
//    } else {
//        _uploadEntity.province_id = [NSNumber numberWithInt:0];
//        _uploadEntity.city_id = [NSNumber numberWithInt:0];
//        _uploadEntity.area_id = [NSNumber numberWithInt:0];
//        _uploadEntity.province = @"";
//        _uploadEntity.city = @"";
//        _uploadEntity.area = @"";
//        _uploadEntity.addr = @"";
//        _uploadEntity.longitude = [NSNumber numberWithInt:0];
//        _uploadEntity.latitude = [NSNumber numberWithInt:0];
//    }
//    
//    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
//        if (contextDidSave) {
//            DLog(@"保存完成了");
//        } else {
//            DLog(@"保存失败了");
//        }
//        
//        if (is_draft == 0) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                //回调或者说是通知主线程刷新，
//                [self uploadPin];
//            });
//        }
//        
//        if (self.onPublish && !_fromDraft) {
//            self.onPublish();
//            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TAB_CHANGE object:self userInfo:@{@"selectedIndex":[NSNumber numberWithInteger:1]}];
//        }
//        self.navigationController.navigationBar.hidden = NO;
//        [self.navigationController popViewControllerAnimated:YES];
//        
//        
//        
//    }];
//    
    
    
}

- (void)updateAtUsers:(NSMutableArray *)users
{
//    DLog(@"updateAtUsers");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        for (int i = 0, j = (int)users.count; i < j; i++) {
//            UserInfo *user = [users objectAtIndex:i];
//            [StringUtils updateTextViewTextInsertedString:self.textView withText:[NSString stringWithFormat:@"@%@ ",user.username] isTag:NO];
//            DLogE(@"self.textView : %@", self.textView.text);
//        }
//    });
    
}

- (void)updateAtAllUsers
{
    DLog(@"updateAtAllUsers");
    _atUsers = @"";
    
    for (UserInfo *user in _friends) {
        NSString *userId = [NSString stringWithFormat:@"%ld",user.user_id];
        if (![_atUsersArray containsObject:userId]) {
            [_atUsersArray addObject:userId];
        }
    }
    
    for (int i = 0, j = (int)_atUsersArray.count; i < j; i++) {
        _atUsers = [_atUsers stringByAppendingString:[_atUsersArray objectAtIndex:i]];
        if (i < (j-1)) {
            _atUsers = [_atUsers stringByAppendingString:@","];
        }
    }
    
    DLog(@"_atUsers : %@", _atUsers);
    
}

-(void)resignTextView
{
//    [self.textView resignFirstResponder];
}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
}

-(void) keyboardWillHide:(NSNotification *)note{
}


#pragma actionSheet delegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
       
}


@end
