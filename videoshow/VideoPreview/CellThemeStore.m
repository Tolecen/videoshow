//
//  CellThemeStore.m
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "CellThemeStore.h"
#import "UIImageView+WebCache.h"
#import "CircleProgress.h"
#import "BabyFileDownloadManager.h"

@interface CellThemeStore()

@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIButton *downloadBtn;
@property (nonatomic, strong) UILabel *themeName;
@property (nonatomic, strong) UILabel *themeDre;
@property (nonatomic, strong) UIImageView *image_shadow;
@property (nonatomic, strong) CircleProgress *mCircleProgress;

@end

@implementation CellThemeStore

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _bgImageView = [[UIImageView alloc]init];
    _bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _bgImageView.clipsToBounds = YES;
    _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    
    _image_shadow = [[UIImageView alloc]initWithImage:ImageNamed(@"shadow_asset")];
    
    _iconImageView = [[UIImageView alloc]init];
    
    _downloadBtn = [[UIButton alloc]init];
    [_downloadBtn addTarget:self action:@selector(inner_downBtn) forControlEvents:UIControlEventTouchUpInside];
    [_downloadBtn setBackgroundImage:ImageNamed(@"ic_mv_download") forState:UIControlStateNormal];
    [_downloadBtn setBackgroundImage:ImageNamed(@"ic_mv_download") forState:UIControlStateHighlighted];
    [_downloadBtn setBackgroundImage:ImageNamed(@"ic_mv_download_done") forState:UIControlStateDisabled];
    
    _themeName = [[UILabel alloc]init];
    _themeName.font = kFontSize(18);
    _themeName.text = @"MV名称";
    _themeName.numberOfLines = 0;
    _themeName.textColor = [UIColor whiteColor];
    _themeName.shadowColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
    
    _themeDre = [[UILabel alloc]init];
    _themeDre.font = kFontSizeNormal;
    _themeDre.text = @"MV名简介";
    _themeDre.numberOfLines = 0;
    _themeDre.textColor = [UIColor whiteColor];
    _themeDre.shadowColor = [UIColor colorWithWhite:0.8f alpha:0.8f];
    
    [self.contentView sd_addSubviews:@[_bgImageView, _image_shadow, _iconImageView, _downloadBtn, _themeName, _themeDre]];
    
    _bgImageView.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(SCREEN_WIDTH / 2)
    .topEqualToView(self.contentView)
    .leftEqualToView(self.contentView);
    
    _iconImageView.sd_layout
    .widthIs(90)
    .heightIs(90)
    .centerYEqualToView(self.contentView)
    .leftSpaceToView(self.contentView, 20);
    
    _downloadBtn.sd_layout
    .widthIs(40)
    .heightIs(40)
    .centerYEqualToView(self.contentView)
    .rightSpaceToView(self.contentView, 20);
    
    _themeName.sd_layout
    .leftSpaceToView(_iconImageView, 20)
    .rightSpaceToView(_downloadBtn, 20)
    .centerYEqualToView(self.contentView)
    .autoHeightRatio(0);
    
    _themeDre.sd_layout
    .leftSpaceToView(self.contentView, 20)
    .rightSpaceToView(self.contentView, 20)
    .bottomSpaceToView(self.contentView, 10)
    .autoHeightRatio(0);
    
    _image_shadow.sd_layout
    .widthIs(SCREEN_WIDTH)
    .heightIs(90)
    .bottomEqualToView(self.contentView)
    .leftEqualToView(self.contentView);
    
    self.mCircleProgress = [[CircleProgress alloc] initWithCenter:CGPointMake(CGRectGetMaxX(_downloadBtn.frame) - (_downloadBtn.bounds.size.width) / 2, CGRectGetMaxY(_downloadBtn.frame) -(_downloadBtn.bounds.size.height) / 2)
                                                           radius:40 / 2
                                                        lineWidth:40 / 2
                                                     progressMode:THProgressModeFill
                                                    progressColor:UIColorFromRGB(BABYCOLOR_comment_text)
                                           progressBackgroundMode:THProgressBackgroundModeCircle
                                          progressBackgroundColor:[UIColor colorWithRed:0.96f green:0.96f blue:0.96f alpha:0.9f]
                                                       percentage:0.0f];
    self.mCircleProgress.layer.zPosition = 1001;
    self.mCircleProgress.hidden = YES;
    [self.contentView addSubview:self.mCircleProgress];
    
    _mCircleProgress.sd_layout
    .widthIs(40)
    .heightIs(40)
    .centerYEqualToView(self.contentView)
    .rightSpaceToView(self.contentView, 20);
    
}

- (void)inner_downBtn
{
    if (self.downloadClicked) {
        self.downloadClicked(_cellIndex, _mVideoTheme);
    }
}

- (void)setMVideoTheme:(VideoTheme *)mVideoTheme
{
    _mVideoTheme = mVideoTheme;
    
    [_bgImageView sd_setImageWithURL:[NSURL URLWithString:mVideoTheme.banner] placeholderImage:nil];
    
    [_iconImageView sd_setImageWithURL:[NSURL URLWithString:mVideoTheme.themeIcon] placeholderImage:nil];
    
    _themeName.text = mVideoTheme.themeDisplayName;
    _themeDre.text = mVideoTheme.desc;
    
    switch (mVideoTheme.status) {
        case FileDownloadStateFinish:
            self.mCircleProgress.hidden = YES;
            self.downloadBtn.hidden = NO;
            self.downloadBtn.enabled = NO;
            break;
        case FileDownloadStateWaiting: {
            self.mCircleProgress.hidden = YES;
            self.downloadBtn.hidden = NO;
            self.downloadBtn.enabled = YES;
            break;
        }
        case FileDownloadStateDownloading: {
            self.mCircleProgress.hidden = NO;
            self.mCircleProgress.percentage = mVideoTheme.percent;
            self.downloadBtn.hidden = YES;
            self.downloadBtn.enabled = NO;
            break;
        }
        case FileDownloadStateSuspending: {
            self.mCircleProgress.hidden = YES;
            self.downloadBtn.hidden = NO;
            self.downloadBtn.enabled = YES;
            break;
        }
        case FileDownloadStateFail: {
            //失败的需要重新加入到队列中
            self.mCircleProgress.hidden = YES;
            self.downloadBtn.hidden = NO;
            self.downloadBtn.enabled = YES;
            break;
        }
        default:
            break;
    }
}

@end
