//
//  VideoPreviewViewController.m
//  Babypai
//
//  Created by ning on 16/5/5.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "VideoPreviewViewController.h"
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
#import "VS_Choose_AlertView.h"
#import "lz_VideoTemplateModel.h"

#define THEME_ENABLE_MAX 20*1000

@interface VideoPreviewViewController ()<UITableViewDelegate, UITableViewDataSource, MenuHrizontalDelegate>

@property (nonatomic, strong) NSURL *url;

@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *themeArray;
@property (nonatomic, strong) NSMutableArray *filterArray;
@property (nonatomic, strong) VideoTheme *mCurrentTheme;
@property (nonatomic, strong) VideoTheme *mCurrentFilter;

@property (nonatomic, assign) BABYVIDEO_THEME_FILTER themeType;

@property (nonatomic, assign) BOOL mStartEncoding;

@property (strong, nonatomic) UIButton *closeButton;

@property (strong, nonatomic) NSArray * watermarkArray;

/**
 * 导演签名
 */
@property (nonatomic, strong) NSString *mAuthor;

/**
 * 导演签名图片
 */
@property (nonatomic, strong) NSString *mAuthorBitmapPath;

/**
 * 导演签名位于视频的x位置
 */
@property (nonatomic, assign) int mAuthorPositionx;


/**
 * 导出视频，导出封面
 */
@property (nonatomic, strong) NSString *mVideoPath, *mCoverPath;

/**
 * 临时合并视频流
 */
@property (nonatomic, strong) NSString *mVideoTempPath;

/**
 * 公共文件
 */
@property (nonatomic, strong) NSString *mThemeCommonPath;
/**
 * 当前Filter路径
 */
@property (nonatomic, strong) NSString *mCurrentFilterPath;

/**
 * 当前MV路径
 */
@property (nonatomic, strong) NSString *mCurrentMVPath;
/**
 * 当前音乐路径
 */
@property (nonatomic, strong) NSString *mCurrentMusicPath;

/**
 * 视频时长
 */
@property (nonatomic, assign) int mDuration;



@property (nonatomic, strong) MenuHrizontal *themeFilterMenu;

@property (nonatomic, strong) UIButton *originMusic;
@property (nonatomic, strong) UIButton *shuiwenBtn;

@property (nonatomic, strong) NSArray *videoFilter;

/**
 *  被选中的theme
 */
@property (nonatomic,strong)NSIndexPath *selectThemePath;

/**
 *  被选中的filter
 */
@property (nonatomic,strong)NSIndexPath *selectFilterPath;

/**
 *  是否有新的Theme下载了
 */
@property (nonatomic, assign) BOOL isDownloadTheme;

@end

@implementation VideoPreviewViewController

- (NSString *)title
{
    return @"编辑视频";
}

- (instancetype)initWithMediaObject:(MediaObject *)mediaObject
{
    self = [self init];
    if (self) {
        self.mMediaObject = mediaObject;
    }
    return self;
}

- (instancetype)initWithVideoUrl:(NSString *)url
{
    self = [self init];
    if (self) {
        self.mVideoTempPath = url;
        self.url = [NSURL URLWithString:url];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.watermarkArray = [NSArray array];
//    self.view.backgroundColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    self.view.backgroundColor = [UIColor whiteColor];


//    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNaviBar];
    [self initData];
    [self initVideoThemes];
    [self initButtons];
    [self initPreview];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(BABYCOLOR_bg_publish);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    [self.navigationController setNavigationBarHidden:YES animated:NO];

    
    [self installMovieNotificationObservers];
    [self.player playWithURLString:_mVideoTempPath withFilters:nil];
//    [self.player prepareToPlay];
    
    
//    if (self.mMediaObject != nil && [self.mMediaObject getDuration] > THEME_ENABLE_MAX) {
//        _themeType = BABYVIDEO_FILTER;
//    } else {
//        _themeType = BABYVIDEO_THEME;
//    }
//    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (_isDownloadTheme) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSUInteger ii[2] = {0, [self.tableView numberOfRowsInSection:0] - 1};
            NSIndexPath* indexPath = [NSIndexPath indexPathWithIndexes:ii length:2];
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        });
        _isDownloadTheme = NO;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    self.navigationController.navigationBar.barTintColor = UIColorFromRGB(BABYCOLOR_base_color);
    //[MobClick endLogPageView:[self title]];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}
- (void)pressCloseButton
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)initNaviBar
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
    .topSpaceToView(self.view, 16)
    .leftSpaceToView(self.view, 5);
    
    
    
    CGSize rightTexttSize = [@"下一步" sizeWithAttributes:@{NSFontAttributeName: kFontSize(18)}];
    
    UIButton *rightButton = [[UIButton alloc]initWithFrame:CGRectMake(colorBack.frame.size.width-85.0f, 26.0f, rightTexttSize.width + 16, rightTexttSize.height)];
    rightButton.titleLabel.font = kFontSize(18);
    [rightButton addTarget:self action:@selector(pressNextButton) forControlEvents:UIControlEventTouchUpInside];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"下一步" titleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [rightButton setImageRight:[UIImage imageNamed:@"baby_icn_next"] withTitle:@"下一步" titleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    
    
    [colorBack addSubview:rightButton];
    
}
- (void)initUserInfo
{
    [super initUserInfo];
    self.mAuthor = [NSString stringWithFormat:@"%@ 作品",[self loginUserInfomation].info.username];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 生成签名
//        UIImage *image = [ImageUtils imageFromText:@[self.mAuthor] withFont:16.0f];
        UIImage *image = [ImageUtils imageFromTextOriginWith:self.mAuthor withFont:20.0f];
        _mAuthorBitmapPath = [[BabyFileManager manager] updateVideoAuthorLogo:image];
        _mAuthorPositionx = ((480 - image.size.width) / 2);
    });
}

- (void)initData
{
    if (self.mMediaObject != nil) {
        self.mVideoTempPath = [self.mMediaObject getOutputTempVideoPath];
        self.url = [NSURL URLWithString:self.mVideoTempPath];
        self.mDuration = [self.mMediaObject getDuration];
        
        self.mVideoPath = self.mMediaObject.mOutputVideoPath;
        self.mCoverPath = [self.mVideoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
        
        self.mThemeCommonPath = [[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:THEME_VIDEO_COMMON];
        
    } else {
        // 做测试用
        self.mDuration = 6000;
        
        self.mVideoPath = [[[BabyFileManager manager] themeDir] stringByAppendingString:[self.mVideoTempPath lastPathComponent]];
        self.mCoverPath = [self.mVideoPath stringByReplacingOccurrencesOfString:@".mp4" withString:@".jpg"];
        
        
        self.mThemeCommonPath = [[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:THEME_VIDEO_COMMON];
        //self.mThemeCommonPath+frame_overlay_black.png
        
        
    }
    self.videoFilter = nil;
    _isDownloadTheme = NO;
}

- (void)initPreview
{
#ifdef DEBUG
    [IJKFFMoviePlayerController setLogReport:YES];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_DEBUG];
#else
    [IJKFFMoviePlayerController setLogReport:NO];
    [IJKFFMoviePlayerController setLogLevel:k_IJK_LOG_INFO];
#endif
    
    [IJKFFMoviePlayerController checkIfFFmpegVersionMatch:YES];
    // [IJKFFMoviePlayerController checkIfPlayerVersionMatch:YES major:1 minor:0 micro:0];
    
    IJKFFOptions *options = [IJKFFOptions optionsByDefault];
    
    self.player = [[IJKFFMoviePlayerController alloc] initWithContentURL:self.url withFilters:self.videoFilter withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = CGRectMake(0, NavigationBar_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH);
    self.player.scalingMode = IJKMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    
    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    
    
//    CALayer *layer = [[CALayer alloc] init];
//    [layer setFrame:CGRectMake(0.0f, self.player.view.frame.size.height, self.view.frame.size.width,600.0f)];
//    [layer setBackgroundColor:[UIColor blackColor].CGColor];
//    [self.player.view.layer addSublayer:layer];
//    
//    
//    CALayer *layerTop = [[CALayer alloc] init];
//    [layerTop setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width,0.0f)];
//    [layerTop setBackgroundColor:[UIColor blackColor].CGColor];
//    [self.player.view.layer addSublayer:layerTop];
//    
//    
//    
//    [layer setFrame:CGRectMake(0.0f,self.player.view.layer.frame.size.height-(640-_outputHeight)/2.0f, self.view.frame.size.width,600.0f)];
//    [layerTop setFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width,(640-_outputHeight)/2.0f)];
//    
    
    
    
    self.mediaControl = [[BabyMediaControl alloc]initWithFrame:CGRectMake(0, NavigationBar_HEIGHT, SCREEN_WIDTH, SCREEN_WIDTH)];
    [self.mediaControl showLoading:NO];
    [self.view addSubview:self.mediaControl];
    
    self.mediaControl.delegatePlayer = self.player;
    [self.mediaControl hideAndRefresh];
    
    
    


//    layer.hidden = YES;
//    layerTop.hidden = YES;
    
    
}

- (void)initButtons
{
    UIView *line = [[UIView alloc]init];
    line.backgroundColor = UIColorFromRGB(BABYCOLOR_background_gray);
    [self.view addSubview:line];
    line.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(.5)
    .bottomSpaceToView(_tableView, 10);
    
    
    _themeFilterMenu = [[MenuHrizontal alloc]init];
    _themeFilterMenu.delegate = self;
    [self.view addSubview:_themeFilterMenu];
    
    _themeFilterMenu.sd_layout
    .widthIs(100)
    .heightIs(30)
    .leftSpaceToView(self.view, 20)
    .bottomSpaceToView(line, 0);
    
    if (_outputHeight!=480) {
        NSArray *vButtonItemArray = @[@{NOMALKEY: @"baby_color_publish_bg",
                                        HEIGHTKEY:@"baby_color_red_height",
                                        TITLEKEY:@"滤镜",
                                        TITLEWIDTH:[NSNumber numberWithInt:50]
                                        }
                                      ];
        [_themeFilterMenu createMenuItems:vButtonItemArray];
        [_themeFilterMenu clickButtonAtIndex:0];
    } else {
        NSArray *vButtonItemArray = @[@{NOMALKEY: @"baby_color_publish_bg",
                                        HEIGHTKEY:@"baby_color_red_height",
                                        TITLEKEY:@"滤镜",
                                        TITLEWIDTH:[NSNumber numberWithInt:50]
                                        },
                                      @{NOMALKEY: @"baby_color_publish_bg",
                                        HEIGHTKEY:@"baby_color_red_height",
                                        TITLEKEY:@"MV",
                                        TITLEWIDTH:[NSNumber numberWithInt:50]
                                        },
                                      ];
        [_themeFilterMenu createMenuItems:vButtonItemArray];
        [_themeFilterMenu clickButtonAtIndex:1];
    }
    
    _originMusic = [[UIButton alloc]init];
//    [_originMusic setImage:ImageNamed(@"preview_music_original") forState:UIControlStateNormal];
//    [_originMusic setImage:ImageNamed(@"preview_music_original_disable") forState:UIControlStateSelected];
    [_originMusic setTitle:@"关闭原音" forState:UIControlStateNormal];
    [_originMusic setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_originMusic addTarget:self action:@selector(pressOriginMusicButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_originMusic];
    _originMusic.tag = 1;
    
    _originMusic.sd_layout
    .widthIs(86)
    .heightIs(36)
    .rightSpaceToView(self.view, 10)
    .bottomSpaceToView(line, 0);
    
    
    
    _shuiwenBtn = [[UIButton alloc]init];
    //    [_originMusic setImage:ImageNamed(@"preview_music_original") forState:UIControlStateNormal];
    //    [_originMusic setImage:ImageNamed(@"preview_music_original_disable") forState:UIControlStateSelected];
    [_shuiwenBtn setTitle:@"自定义水印" forState:UIControlStateNormal];
    [_shuiwenBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_shuiwenBtn addTarget:self action:@selector(initShuiYin) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_shuiwenBtn];
    
    
    _shuiwenBtn.sd_layout
    .widthIs(106)
    .heightIs(36)
    .rightSpaceToView(self.view, 120)
    .bottomSpaceToView(line, 0);

    
}
-(void)initShuiYin
{
    
    
    //弹出水印选项弹窗
//    VS_Choose_AlertView *vc = [[VS_Choose_AlertView alloc] initWithFrame:[UIScreen mainScreen].bounds];
//    [vc setTitles:@[@"文字水印",@"图片水印"]];
//    vc.block = ^(WaterMarkType WaterMarkType){
//        
//        if (WaterMarkType == WaterMarkType_TextWaterMark) {//如果去水印
//            
//           
//        }else if (WaterMarkType == WaterMarkType_PicWaterMark) {//不去水印
//            
//            
//        }else{}
//    };
//    [vc show];
    
    [self getShuiYinList];
    
}

-(void)getShuiYinList
{
    [lz_VideoTemplateModel requestUserWaterListWithPage:0 length:0 SuccessHandle:^(id responseObject) {
        
    } FailureHandle:^(NSError *error) {
        
    }];
}
- (void)initVideoThemes
{
    
    _themeArray = [[NSMutableArray alloc]init];
    _filterArray = [[NSMutableArray alloc]init];
    
    self.tableView = [[UITableView alloc]init];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView.layer setAnchorPoint:CGPointMake(0.0, 0.0)];
    self.tableView.transform = CGAffineTransformMakeRotation(M_PI/-2);
    self.tableView.showsVerticalScrollIndicator = NO;
    self.tableView.frame = CGRectMake(0, SCREEN_HEIGHT, SCREEN_WIDTH, CELL_THEME_H);
    self.tableView.rowHeight = CELL_THEME_W;
    
    
    [self.view addSubview:self.tableView];
    [self.tableView registerClass:[CellTheme class] forCellReuseIdentifier:NSStringFromClass([CellTheme class])];
    
    [self loadThemesData];
}

- (void)loadThemesData
{
    if (_mStartEncoding) {
        return;
    }
    
    if (_themeArray) {
        [_themeArray removeAllObjects];
    }
    if (_filterArray) {
        [_filterArray removeAllObjects];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 处理耗时操作的代码块...
        
        NSString *file = [[ThemeHelper helper]prepareTheme];
        
        if (![StringUtils isEmpty:file]) {
            _themeArray = [[ThemeHelper helper] parseTheme:THEME_MUSIC_VIDEO_ASSETS themeNames:themesIn];
        
        
            NSMutableArray *downloadThemeList = [[ThemeHelper helper] parseTheme:THEME_DOWNLOAD_VIDEO themeNames:nil];
            
            [_themeArray addObjectsFromArray:downloadThemeList];
            
            VideoTheme *storeTheme = [[ThemeHelper helper] loadThemeRes:THEME_STORE themeDisplayName:THEME_STORE_NAME themeIconResource:@"ic_more_mv_normal"];
            if (storeTheme != nil)
                [_themeArray insertObject:storeTheme atIndex:0];
            
            VideoTheme *emptyTheme = [[ThemeHelper helper] loadThemeJson:[[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:THEME_EMPTY]];
            if (emptyTheme != nil)
                [_themeArray insertObject:emptyTheme atIndex:1];
        }
        _filterArray = [[ThemeHelper helper] parseTheme:THEME_FILTER_ASSETS themeNames:filterIn];
        
        //通知主线程刷新
        dispatch_async(dispatch_get_main_queue(), ^{
            //回调或者说是通知主线程刷新，
            
            // 默认选中行
            if (_themeType == BABYVIDEO_THEME) {
                _selectThemePath = [NSIndexPath indexPathForRow:1 inSection:0];
            } else {
                _selectFilterPath = [NSIndexPath indexPathForRow:0 inSection:0];
            }
            [self.tableView reloadData];
            
        });
        
    });

}

- (void)pressOriginMusicButton
{
     [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    if (_originMusic.tag==1) {
        [SVProgressHUD showErrorWithStatus:@"原音关闭"];
        _originMusic.tag = 2;
        [_originMusic setTitle:@"开启原音" forState:UIControlStateNormal];
    }
    else
    {
         [SVProgressHUD showSuccessWithStatus:@"原音开启"];
        _originMusic.tag= 1;
        [_originMusic setTitle:@"关闭原音" forState:UIControlStateNormal];
    }
   

    [self restartPlayer];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void)pressNextButton
{
    NSLog(@"pressNextButton------");
    [self.player pause];
    [self.mediaControl showNoFade];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeBlack];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD showProgress:0 status:@"生成视频中"];
    
    __block VideoPreviewViewController *blockSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // 生成视频
        int videoTime = _mDuration / 1000 + 2;
        
        NSString *filterTheme = @"";
        if (![StringUtils isEmpty:_mCurrentFilterPath]) {
            filterTheme = [NSString stringWithFormat:@"[mv2];[mv2]curves=psfile=%@", _mCurrentFilterPath];
        }
        
        VideoEncoder *encoder = [VideoEncoder videoEncoder];
        
        NSMutableArray *mutableArray = [[NSMutableArray alloc]init];
        
        [mutableArray addObject:@"ffmpeg"];
        [mutableArray addObject:@"-y"];
        [mutableArray addObject:@"-i"];
        [mutableArray addObject:_mVideoTempPath];
        
        
//        if (_outputHeight==480) {
//            [mutableArray addObject:@"-itsoffset"];
//            [mutableArray addObject:[NSString stringWithFormat:@"%d",(videoTime - 2)]];
//            [mutableArray addObject:@"-i"];
//            [mutableArray addObject:[_mThemeCommonPath stringByAppendingPathComponent:@"tail.mp4"]];
//        }
//
//        
//        
//        [mutableArray addObject:@"-i"];
//        [mutableArray addObject:_mAuthorBitmapPath];
        
        
//        if (_outputHeight==480) {
//            if (_themeType == BABYVIDEO_FILTER || [StringUtils isEmpty:_mCurrentMVPath]) {
//                _mCurrentMVPath = [_mThemeCommonPath stringByAppendingPathComponent:@"black.mp4"];
//            }
//            [mutableArray addObject:@"-itsoffset"];
//            [mutableArray addObject:@"0"];
//            [mutableArray addObject:@"-i"];
//            [mutableArray addObject:_mCurrentMVPath];
//        }
        
        
        if (self.isCircle) {
            NSString * overlayPath = [[[[BabyFileManager manager] themeDir] stringByAppendingPathComponent:@"Common"]stringByAppendingPathComponent:@"frame_overlay_black.png"];
            //        UIImage * image = [UIImage imageWithContentsOfFile:overlayPath];
            
            [mutableArray addObject:@"-i"];
            [mutableArray addObject:overlayPath];
        }
       
        
        
        
        
        [mutableArray addObject:@"-filter_complex"];
        
        NSString *filter = @"";
        if (_outputHeight==480) {
            if (!self.isCircle) {
                filter = [NSString stringWithFormat:@"[0:v]format=rgb24,setsar=sar=1/1[mv];[3:v]format=rgb24,setsar=sar=1/1[in];[in][mv]blend=all_mode='addition':all_opacity=1,format=rgb24[tmp];[tmp] boxblur=luma_radius=min(h\\,w)/30:luma_power=1:chroma_radius=min(cw\\,ch)/30:chroma_power=1:enable='between(t,%d,%d)'[tmpblur];[tmpblur]format=rgb24,setsar=sar=1/1[mv];[1:v]format=rgb24,setsar=sar=1/1[tail];[mv][tail]blend=all_mode='addition':all_opacity=1,format=rgb24[tmpblur2];[tmpblur2][2:v]overlay=%d:260:enable='between(t,%d,%d)'%@",(videoTime - 2), videoTime, _mAuthorPositionx, (videoTime - 2), videoTime, filterTheme];
            }
            else
            {
                filter = [NSString stringWithFormat:@"[0:v]format=rgb24,setsar=sar=1/1[mv];[3:v]format=rgb24,setsar=sar=1/1[in];[in][mv]blend=all_mode='addition':all_opacity=1,format=rgb24[tmp];[tmp] boxblur=luma_radius=min(h\\,w)/30:luma_power=1:chroma_radius=min(cw\\,ch)/30:chroma_power=1:enable='between(t,%d,%d)'[tmpblur];[tmpblur]format=rgb24,setsar=sar=1/1[mv];[1:v]format=rgb24,setsar=sar=1/1[tail];[mv][tail]blend=all_mode='addition':all_opacity=1,format=rgb24[tmpblur2];[tmpblur2][2:v]overlay=%d:260:enable='between(t,%d,%d)'[maskcircle];[maskcircle][4:v]overlay=0:0%@",(videoTime - 2), videoTime, _mAuthorPositionx, (videoTime - 2), videoTime,filterTheme];
            }
            

        }
        else
        {
            filter = [NSString stringWithFormat:@"[0:v] boxblur=luma_radius=min(h\\,w)/30:luma_power=1:chroma_radius=min(cw\\,ch)/30:chroma_power=1:enable='between(t,%d,%d)'[tmpblur];[tmpblur]format=rgb24,setsar=sar=1/1[mv];[mv][1:v] overlay=%d:260:enable='between(t,%d,%d)'%@",(videoTime - 2), videoTime, _mAuthorPositionx, (videoTime - 2), videoTime, filterTheme];
        }
        [mutableArray addObject:filter];
        
        NSString *aFilter;
        
        if (_themeType == BABYVIDEO_THEME) {
        
            if (![StringUtils isEmpty:_mCurrentMusicPath]) {
                if (_originMusic.tag==2) {
                    
                    aFilter = [NSString stringWithFormat:@"amovie=%@[audio];[in]volume=0.0[in];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 2), (videoTime - 2)];
                    
                } else {
                    aFilter = [NSString stringWithFormat:@"amovie=%@[audio];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 2), (videoTime - 2)];
                }
            } else if (_originMusic.tag==2) {
                aFilter = @"[in]volume=0.0[in]";
            } else {
                aFilter = [NSString stringWithFormat:@"[in]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", (videoTime - 2), (videoTime - 2)];
            }
            
        } else {
            if (_originMusic.tag==2) {
                aFilter = @"[in]volume=0.0[in]";
            } else {
                aFilter = [NSString stringWithFormat:@"[in]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", (videoTime - 2), (videoTime - 2)];
            }
            
        }
        
        [mutableArray addObject:@"-af"];
        [mutableArray addObject:aFilter];
        
        [mutableArray addObject:@"-t"];
        [mutableArray addObject:[NSString stringWithFormat:@"%d", videoTime]];
        [mutableArray addObject:@"-b:v"];
        [mutableArray addObject:@"1.0M"];
        [mutableArray addObject:@"-c:a"];
        [mutableArray addObject:@"libfaac"];
        [mutableArray addObject:@"-strict"];
        [mutableArray addObject:@"-2"];
        [mutableArray addObject:@"-c:v"];
        [mutableArray addObject:@"libx264"];
        [mutableArray addObject:@"-pix_fmt"];
        [mutableArray addObject:@"yuv420p"];
        [mutableArray addObject:@"-absf"];
        [mutableArray addObject:@"aac_adtstoasc"];
        [mutableArray addObject:@"-movflags"];
        [mutableArray addObject:@"+faststart"];
        [mutableArray addObject:_mVideoPath];
        
        
        NSArray *array =[mutableArray copy];
        
        OnEncoderProgressBlock progressBlock = ^(long size, long timestamp) {
            float progress = (double)timestamp / (videoTime * 1000 * 1000);
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
                [blockSelf saveToUploadInfo];
                
                
                [SVProgressHUD dismiss];
                
            });
            
        };
        
        [encoder videoMerge:array progress:progressBlock completion:block];
    });
    

}

- (void)saveToUploadInfo
{
    /**
     *  为了测试，copy到手机相册，后期去掉
     */
    BabyFileManager *fm = [BabyFileManager new];
    [fm copyFileToCameraRoll:[NSURL fileURLWithPath:_mVideoPath]];
    
    UIImage *image = [ImageUtils getVideoPreViewImage:_mVideoPath withTime:_mDuration / 1000 / 2];
    
    _mCoverPath = [[BabyFileManager manager]saveUIImageToPath:_mCoverPath withImage:image];
    
    NSString *path = [[BabyFileManager manager] getCurrentDocumentPath];
    
    NSString *saveObjDir = [self.mMediaObject getObjectFilePath];
    
    NSDictionary *mMediaObjectDict = [[BabyFileManager manager] convertMediaObject:self.mMediaObject].mj_keyValues;
    NSString *mMediaObjectStr = [Utils dataTOjsonString:mMediaObjectDict];
    mMediaObjectStr = [mMediaObjectStr stringByReplacingOccurrencesOfString:[[BabyFileManager manager]getCurrentDocumentPath] withString:@""];
    
    NSString *objectFilePath = [BabyFileManager saveStringToFile:saveObjDir concatText:mMediaObjectStr];
    DLog(@"objectFilePath : %@", objectFilePath);
    
    NSString *file_image_original = [_mCoverPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", path] withString:@""];
    
    BabyUploadEntity *uploadInfo;
    if (_fromDraft) {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"file_image_original=%@", file_image_original];
        uploadInfo = [BabyUploadEntity MR_findFirstWithPredicate:filter];

    } else {
        uploadInfo = [BabyUploadEntity MR_createEntity];
    }

    uploadInfo.file_image_original = file_image_original;
    uploadInfo.file_image_path = [_mCoverPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", path] withString:@""];
    uploadInfo.file_format = FILE_FORMAT_VIDEO;
    uploadInfo.file_video_path = [_mVideoPath stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", path] withString:@""];
    uploadInfo.file_video_obj = @"";
    uploadInfo.file_time = [NSNumber numberWithLong:[[NSDate date] timeIntervalSince1970]];
    uploadInfo.file_video_time = [NSNumber numberWithInt:[StringUtils videoTime:_mDuration]];
    uploadInfo.file_isupload = [NSNumber numberWithInt:0];
    uploadInfo.user_id = [NSNumber numberWithLong:[self loginUserId]];
    uploadInfo.board_id = [NSNumber numberWithInt:0];
    uploadInfo.board_name = @"";
    uploadInfo.raw_text = @"";
    uploadInfo.at_uid = @"";
    uploadInfo.tags = _tag;
    uploadInfo.tag_id = [NSString stringWithFormat:@"%ld", _tag_id];
    uploadInfo.media_object = [objectFilePath stringByReplacingOccurrencesOfString:[[BabyFileManager manager] getCurrentDocumentPath] withString:@""];
    uploadInfo.is_private = [NSNumber numberWithInt:0];
    uploadInfo.share_qq = [NSNumber numberWithInt:0];
    uploadInfo.share_wb = [NSNumber numberWithInt:0];
    uploadInfo.share_wx = [NSNumber numberWithInt:0];
    if (_fromDraft) {
        uploadInfo.is_draft = [NSNumber numberWithInt:1];
    } else {
        uploadInfo.is_draft = [NSNumber numberWithInt:2];
    }
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if (contextDidSave) {
            DLog(@"保存完成了");
        } else {
            DLog(@"保存失败了");
        }
    }];
    self.mMediaObject = [[BabyFileManager manager] convertBackMediaObject:self.mMediaObject];
    
    
    
    VideoPublishViewController *publishVC = [[VideoPublishViewController alloc]init];
    publishVC.uploadEntity = uploadInfo;
    publishVC.fromDraft = _fromDraft;
    publishVC.mMediaObject = self.mMediaObject;
    publishVC.videoFilter = self.videoFilter;
    publishVC.mVideoTempPath = _mVideoPath;
    
    
    publishVC.savedDraft = ^(BOOL saved) {
        if (self.savedDraft) {
            self.savedDraft(saved);
        }
    };
    
    publishVC.onPublish = ^() {
        if (self.onPublish) {
            self.onPublish();
        }
        [self.navigationController popViewControllerAnimated:YES];
    };
    
    [self.navigationController pushViewController:publishVC animated:YES];
    
    
    
}

- (void)restartPlayer
{
    int videoTime = _mDuration / 1000;
    NSString *filterTheme = @"";
    if (![StringUtils isEmpty:_mCurrentFilterPath]) {
        filterTheme = [NSString stringWithFormat:@"curves=psfile=%@", _mCurrentFilterPath];
    }
    
    NSMutableArray *commanders = [[NSMutableArray alloc]init];
    
    [commanders addObject:@"ffplay"];
    [commanders addObject:_mVideoTempPath];
    
    
    if (_themeType == BABYVIDEO_THEME) {
        
        if (![StringUtils isEmpty:_mCurrentMVPath]) {
            [commanders addObject:@"-t"];
            [commanders addObject:[NSString stringWithFormat:@"%d", videoTime]];
            [commanders addObject:@"-loop"];
            [commanders addObject:@"0"];
            [commanders addObject:@"-vf"];
            
            NSString *filter = [NSString stringWithFormat:@"movie=%@,format=rgb24,setsar=sar=1/1[mv];[in]format=rgb24,setsar=sar=1/1[in];[in][mv]blend=all_mode='addition':repeatlast=0:all_opacity=1,format=rgb24",_mCurrentMVPath];
            
            [commanders addObject:filter];
        }
        
        if (![StringUtils isEmpty:_mCurrentMusicPath]) {
            [commanders addObject:@"-af"];
            
            if (_originMusic.tag==2) {
                [commanders addObject:[NSString stringWithFormat:@"amovie=%@[audio];[in]volume=0.0[in];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 1), (videoTime - 1)]];
            } else {
                [commanders addObject:[NSString stringWithFormat:@"amovie=%@[audio];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 1), (videoTime - 1)]];
            }
        } else if (_originMusic.tag==2) {
            [commanders addObject:@"-af"];
            [commanders addObject:@"[in]volume=0.0[in]"];
        } else {
            [commanders addObject:@"-af"];
            [commanders addObject:[NSString stringWithFormat:@"[in]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", (videoTime - 1), (videoTime - 1)]];
        }
        
    } else {
        
        if (![StringUtils isEmpty:_mCurrentFilterPath]) {
            [commanders addObject:@"-vf"];
            [commanders addObject:filterTheme];
        }
        
        if (_originMusic.tag==2) {
            [commanders addObject:@"-af"];
            [commanders addObject:@"[in]volume=0.0[in]"];
        } else {
            [commanders addObject:@"-af"];
            [commanders addObject:[NSString stringWithFormat:@"[in]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", (videoTime - 1), (videoTime - 1)]];
        }
    }
    
    
//    // 视频滤镜
//    if (![StringUtils isEmpty:_mCurrentMVPath]) {
//        [commanders addObject:@"-t"];
//        [commanders addObject:[NSString stringWithFormat:@"%d", videoTime]];
//        [commanders addObject:@"-loop"];
//        [commanders addObject:@"0"];
//        [commanders addObject:@"-vf"];
//        
//        NSString *filter = [NSString stringWithFormat:@"movie=%@,format=rgb24,setsar=sar=1/1[mv];[in]format=rgb24,setsar=sar=1/1[in];[in][mv]blend=all_mode='addition':repeatlast=0:all_opacity=1,format=rgb24",_mCurrentMVPath];
//        if (![StringUtils isEmpty:_mCurrentFilterPath]) {
//            filter = [filter stringByAppendingString:[NSString stringWithFormat:@"[mv2];[mv2]%@",filterTheme]];
//        }
//        
//        [commanders addObject:filter];
//    } else {
//        if (![StringUtils isEmpty:_mCurrentFilterPath]) {
//            [commanders addObject:@"-vf"];
//            [commanders addObject:filterTheme];
//        }
//    }
    
//    // 音频滤镜
//    if (![StringUtils isEmpty:_mCurrentMusicPath]) {
//        [commanders addObject:@"-af"];
//        
//        if (_originMusic.isSelected) {
//            [commanders addObject:[NSString stringWithFormat:@"amovie=%@[audio];[in]volume=0.0[in];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 1), (videoTime - 1)]];
//        } else {
//            [commanders addObject:[NSString stringWithFormat:@"amovie=%@[audio];[in][audio]amix=inputs=2:duration=shortest:dropout_transition=2[temp];[temp]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", _mCurrentMusicPath, (videoTime - 1), (videoTime - 1)]];
//        }
//    } else if (_originMusic.isSelected) {
//        [commanders addObject:@"-af"];
//        [commanders addObject:@"[in]volume=0.0[in]"];
//    } else {
//        [commanders addObject:@"-af"];
//        [commanders addObject:[NSString stringWithFormat:@"[in]volume='if(lt(t,%d),1,max(1-(t-%d)/1,0))':eval=frame", (videoTime - 1), (videoTime - 1)]];
//    }
    
    self.videoFilter = [commanders copy];
    
    [self.player shutdown];
    
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (_themeType == BABYVIDEO_THEME) {
        NSLog(@"themeArray.count=%lu",(unsigned long)_themeArray.count);
        
        return _themeArray.count;
    } else if(_themeType == BABYVIDEO_FILTER){
        
        NSLog(@"_filterArray.count=%lu",(unsigned long)_filterArray.count);

        return _filterArray.count;
    }else{
        
        return 0;
        
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    CellTheme *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([CellTheme class])];
    cell.backgroundColor = [UIColor clearColor];
    cell.cellIndex = indexPath.row;
    NSIndexPath *selectPath;
    
    if (_themeType == BABYVIDEO_THEME) {
        cell.theme = [_themeArray objectAtIndex:indexPath.row];
        selectPath = _selectThemePath;
        
        [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        if (selectPath == indexPath) {
            cell.selectedView.hidden = NO;
        } else {
            cell.selectedView.hidden = YES;
        }
        
        
    }else if(_themeType == BABYVIDEO_FILTER){
        cell.theme = [_filterArray objectAtIndex:indexPath.row];
        if (_selectFilterPath.row == 0 && indexPath.row == 0) {
            _selectFilterPath = [indexPath copy];
        }
        selectPath = _selectFilterPath;
        
        [cell.contentView setTransform:CGAffineTransformMakeRotation(M_PI/2)];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        
        if (selectPath == indexPath) {
            cell.selectedView.hidden = NO;
        } else {
            cell.selectedView.hidden = YES;
        }
        
    }else
    {
        selectPath =_selectThemePath;
    }
    

    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int newRow = (int)[indexPath row];
    
    
    NSIndexPath *selectPath;
    VideoTheme *theme = nil, *mCurrentT = nil;
    if (_themeType == BABYVIDEO_THEME) {
        theme = [_themeArray objectAtIndex:indexPath.row];
        selectPath = _selectThemePath;
        mCurrentT = _mCurrentTheme;
    } else if(_themeType == BABYVIDEO_FILTER){
        theme = [_filterArray objectAtIndex:indexPath.row];
        selectPath = _selectFilterPath;
        mCurrentT = _mCurrentFilter;
    }else
    {
        
    }
    
    if ([theme.themeName isEqualToString:THEME_STORE]) {
        DLog(@"去商店");
        [self.player pause];
        ThemeStoreViewController *themeVC = [[ThemeStoreViewController alloc]init];
        
        themeVC.onThemeDownload = ^() {
            _isDownloadTheme = YES;
            [self loadThemesData];
        };
        
        BabyNavigationController *themeNav = [[BabyNavigationController alloc]initWithRootViewController:themeVC];
        [self presentViewController:themeNav animated:YES completion:nil];
        
        return;
    }
    
    int oldRow = (int)(selectPath != nil) ? (int)[selectPath row] : -1;
    if(newRow != oldRow) {
        
        CellTheme *newCell = (CellTheme*)[tableView cellForRowAtIndexPath:indexPath];
        newCell.selectedView.hidden = NO;
        CellTheme *oldCell = (CellTheme *)[tableView cellForRowAtIndexPath:selectPath];
        oldCell.selectedView.hidden = YES;
        if (_themeType == BABYVIDEO_THEME) {
            _selectThemePath = [indexPath copy];
        } else {
            _selectFilterPath = [indexPath copy];
        }
        
        
    }
    
    
    if (mCurrentT == nil || ![mCurrentT.themeName isEqualToString:theme.themeName]) {
        // 更改选中样式
        //..........
        
        
        DLog(@"theme.isMv : %d", theme.isMv);
        if (theme.isMv) {
            _mCurrentTheme = theme;
            _mCurrentMusicPath = _mCurrentTheme.musicPath;
            
            if (![_mCurrentTheme.themeName isEqualToString:@"Empty"]) {
                _mCurrentMVPath = [_mCurrentTheme.themeFolder stringByAppendingPathComponent:@"frame.ts"];
                if (![[Utils utils] isFileExists:_mCurrentMVPath]) {
                    _mCurrentMVPath = [_mCurrentTheme.themeFolder stringByAppendingPathComponent:@"frame.mp4"];
                }
                if (![[Utils utils] isFileExists:_mCurrentMVPath]) {
                    _mCurrentMVPath = nil;
                }
            } else {
                _mCurrentMVPath = nil;
            }
            DLog(@"_mCurrentMVPath : %@", _mCurrentMVPath);
        }
        
        if (theme.isFilter) {
            _mCurrentFilter = theme;
            if (![_mCurrentFilter.themeName isEqualToString:@"Empty"]) {
                
                _mCurrentFilterPath = [theme.themeFolder stringByAppendingPathComponent:theme.themeName];
                
            } else {
                _mCurrentFilterPath = nil;
            }
            DLog(@"_mCurrentFilterPath : %@", _mCurrentFilterPath);
        }
        [self restartPlayer];
    }
    
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

#pragma mark - MenuHrizontal delegate
- (void)didMenuHrizontalClickedButtonAtIndex:(NSInteger)aIndex
{
    if (aIndex == 0) {
        _themeType = BABYVIDEO_FILTER;
    } else {
        _themeType = BABYVIDEO_THEME;
    }
    [_tableView reloadData];
    [self restartPlayer];
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
            [self.player playWithURLString:_mVideoTempPath withFilters:_videoFilter];
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
