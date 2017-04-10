//
//  LZ_TestTableViewCell.m
//  AVFoundation_Test
//
//  Created by gutou on 2017/3/12.
//  Copyright © 2017年 gutou. All rights reserved.
//

#import "LZ_TestTableViewCell.h"

#define Cell_Height ([UIScreen mainScreen].bounds.size.height/3)

@interface LZ_TestTableViewCell ()

@property (nonatomic, strong) UIImageView *user_headImageView;
@property (nonatomic, strong) UILabel *user_nameLab;
@property (nonatomic, strong) UILabel *user_titleLab;
@property (nonatomic, strong) UIImageView *user_videoImageView;
@property (nonatomic, strong) UIButton *user_downBtn;
@property (nonatomic, strong) UIButton *user_shareBtn;
@property (nonatomic, strong) UIButton *user_getWaterMarkBtn;

@end

@implementation LZ_TestTableViewCell

+ (instancetype) cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *) reuseIdentifier indexPath:(NSIndexPath *)indexPath;
{
    LZ_TestTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[LZ_TestTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

-(instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self creatView];
    }
    return self;
}

- (void) creatView;
{
    CGFloat x_y = Cell_Height*0.05f;//10
    CGFloat margin = Cell_Height*0.03f;//5
    
    CGFloat headHeight_Width = Cell_Height*0.22f;//50
    
    self.user_headImageView = [[UIImageView alloc] init];
    self.user_headImageView.backgroundColor = UIColorFromRGB(0x858585);
    self.user_headImageView.frame = CGRectMake(x_y, x_y, headHeight_Width, headHeight_Width);
    self.user_headImageView.layer.cornerRadius = headHeight_Width/2;
    [self.contentView addSubview:self.user_headImageView];
    
    CGFloat nameH = Cell_Height*0.14f;//30
    self.user_nameLab = [UILabel new];
    self.user_nameLab.frame = CGRectMake(self.user_headImageView.right+5, self.user_headImageView.top, 100, nameH);
    self.user_nameLab.text = @"视频标题_1";
    [self.user_nameLab adjustsFontSizeToFitWidth];
    [self.contentView addSubview:self.user_nameLab];
    
    CGFloat titleH = Cell_Height*0.1f;//20
    self.user_titleLab = [UILabel new];
    self.user_titleLab.frame = CGRectMake(self.user_headImageView.right+5, self.user_nameLab.bottom, 100, titleH);
    self.user_titleLab.text = @"视频标题_2";
    self.user_titleLab.font = [UIFont systemFontOfSize:12];
    [self.contentView addSubview:self.user_titleLab];
    
    self.videoImv = [[UIImageView alloc] initWithImage:[AppAppearance sharedAppearance].defaultImage];
    self.videoImv.frame = CGRectMake(self.user_titleLab.left, self.user_headImageView.bottom+margin, MainScreenSize.width-(self.user_titleLab.left)*2, Cell_Height*0.6);
    self.videoImv.backgroundColor = UIColorFromRGB(0x858585);
    [self.contentView addSubview:self.videoImv];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapActin)];
    self.videoImv.userInteractionEnabled = YES;
    [self.videoImv addGestureRecognizer:tap];
    
    self.user_downBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.user_downBtn.tag = 10;
    [self.user_downBtn setTitle:@"下载" forState:UIControlStateNormal];
    [self.user_downBtn setTitleColor:UIColorFromRGB(0x929292) forState:UIControlStateNormal];
    self.user_downBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    [self.user_downBtn setImage:[UIImage imageNamed:@"zaixian_03"] forState:UIControlStateNormal];
    [self.user_downBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    self.user_downBtn.frame = CGRectMake(self.videoImv.left, self.videoImv.bottom, 60, titleH);
    [self.contentView addSubview:self.user_downBtn];
    
    self.user_shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.user_shareBtn.tag = 11;
    [self.user_shareBtn setTitle:@"分享" forState:UIControlStateNormal];
    [self.user_shareBtn setTitleColor:self.user_downBtn.currentTitleColor forState:UIControlStateNormal];
    self.user_shareBtn.titleLabel.font = self.user_downBtn.titleLabel.font;
    [self.user_shareBtn setImage:[UIImage imageNamed:@"zaixian_05"] forState:UIControlStateNormal];
    [self.user_shareBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    self.user_shareBtn.frame = CGRectMake(self.user_downBtn.right + 20, self.videoImv.bottom, 60, titleH);
    [self.contentView addSubview:self.user_shareBtn];
    
    self.user_getWaterMarkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.user_getWaterMarkBtn.tag = 12;
    [self.user_getWaterMarkBtn setTitle:@"一键加水印" forState:UIControlStateNormal];
    [self.user_getWaterMarkBtn setTitleColor:self.user_downBtn.currentTitleColor forState:UIControlStateNormal];
    self.user_getWaterMarkBtn.titleLabel.font = self.user_downBtn.titleLabel.font;
    [self.user_getWaterMarkBtn setImage:[UIImage imageNamed:@"zaixian_07"] forState:UIControlStateNormal];
    [self.user_getWaterMarkBtn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
    self.user_getWaterMarkBtn.frame = CGRectMake(self.user_shareBtn.right + 20, self.videoImv.bottom, 80, titleH);
    [self.contentView addSubview:self.user_getWaterMarkBtn];
}

- (void) click:(UIButton *)btn
{
    [SVProgressHUD setMinimumSize:CGSizeMake(100, 100)];
    
    if (btn.tag == 10) {
        
//        [SVProgressHUD showWithStatus:@"下载"];
        if (self.PlayCellBlock) {
            self.PlayCellBlock(0);
        }
        
        [self hudDismiss];
        
    }else if (btn.tag == 11) {
//        [SVProgressHUD showWithStatus:@"分享"];
        
        if (self.PlayCellBlock) {
            self.PlayCellBlock(1);
        }
        [self hudDismiss];
    }else {
//        [SVProgressHUD showWithStatus:@"加水印"];
        
        if (self.PlayCellBlock) {
            self.PlayCellBlock(2);
        }
        [self hudDismiss];
    }
}

//点击播放
- (void) tapActin
{
    if (self.PlayCellBlock) {
        self.PlayCellBlock(99);
    }
}

- (void) hudDismiss
{
    dispatch_time_t deplayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1*NSEC_PER_SEC));
    dispatch_after(deplayTime, dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}

- (void) setModel:(NSArray *)model
{
    //    model = @[@"a",@"b",@"c"];
}

+ (CGFloat)cellHeightWithData:(NSString *)data;
{
    return Cell_Height + 5;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
