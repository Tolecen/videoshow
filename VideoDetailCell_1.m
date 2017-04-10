//
//  VideoDetailCell_1.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VideoDetailCell_1.h"
#import "lz_VideoTemplateModel.h"

@interface VideoDetailCell_1 ()

@property (nonatomic, strong) UILabel *titleLab;
@property (nonatomic, strong) UILabel *lab_11;//时长
@property (nonatomic, strong) UILabel *lab_21;//大小
@property (nonatomic, strong) UILabel *lab_31;//热度
@property (nonatomic, strong) UILabel *lab_41;//是否收费
@property (nonatomic, strong) UILabel *lab_51;//价格

@property (nonatomic, strong) UIImageView *detailImageView;

@end

@implementation VideoDetailCell_1

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self creatView];
    }
    return self;
}

- (void) creatView;
{
    _titleLab = [UILabel new];
    _titleLab.text = @"守着一份执着";
    _titleLab.textColor = UIColorFromRGB(0x2d2d2d);
    _titleLab.font = [UIFont systemFontOfSize:12];
    [_titleLab sizeToFit];
    [self.contentView addSubview:_titleLab];
//    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.contentView.mas_top).offset(12.5);
//        make.left.equalTo(self.contentView.mas_left).offset(6);
//        make.height.mas_offset(_titleLab.height);
//    }];
    _titleLab.frame = CGRectMake(5, 10, self.contentView.width, _titleLab.height);
    
    self.detailImageView = [[UIImageView alloc] init];
//    detailImageView.image = nil;
//    [detailImageView sizeToFit];
    self.detailImageView.backgroundColor = [UIColor redColor];
    self.detailImageView.frame = CGRectMake(_titleLab.left, _titleLab.bottom + 5, self.contentView.width-10, 100);
    [self.contentView addSubview:self.detailImageView];
//    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(_titleLab.mas_bottom).offset(5);
//        make.left.equalTo(_titleLab.mas_left);
//        make.right.equalTo(_titleLab.mas_right);
//        make.height.mas_equalTo(100);
//    }];
    
    UILabel *lab_1 = [self createGrayLabel];
    lab_1.text = @"时长：";
    [lab_1 sizeToFit];
    [self.contentView addSubview:lab_1];
    [lab_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailImageView.mas_bottom).offset(5);
        make.left.equalTo(self.detailImageView.mas_left).offset(5.5);
        make.height.mas_equalTo(lab_1.height);
        make.width.mas_offset(lab_1.width);
    }];
    
    _lab_11 = [self createGrayLabel];
    [self.contentView addSubview:_lab_11];
    [_lab_11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_1.mas_top);
        make.left.equalTo(lab_1.mas_right);
        make.height.equalTo(lab_1.mas_height);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    UILabel *lab_2 = [self createGrayLabel];
    lab_2.text = @"大小：";
    [self.contentView addSubview:lab_2];
    [lab_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_1.mas_top);
        make.left.equalTo(self.contentView.mas_centerX).offset(5);
        make.height.equalTo(lab_1.mas_height);
        make.width.equalTo(lab_1.mas_width);
    }];
    
    _lab_21 = [self createGrayLabel];
    [self.contentView addSubview:_lab_21];
    [_lab_21 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_2.mas_top);
        make.left.equalTo(lab_2.mas_right);
        make.height.equalTo(lab_2.mas_height);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    UILabel *lab_3 = [self createGrayLabel];
    lab_3.text = @"热度：";
    [self.contentView addSubview:lab_3];
    [lab_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_1.mas_bottom).offset(5);
        make.left.equalTo(lab_1.mas_left);
        make.height.equalTo(lab_1.mas_height);
        make.width.equalTo(lab_1.mas_width);
    }];
    
    _lab_31 = [self createGrayLabel];
    [self.contentView addSubview:_lab_31];
    [_lab_31 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_3.mas_top);
        make.left.equalTo(lab_3.mas_right);
        make.height.equalTo(lab_3.mas_height);
        make.right.equalTo(self.contentView.mas_right);
    }];
    
    UILabel *lab_4 = [self createGrayLabel];
    lab_4.text = @"费用：";
    [self.contentView addSubview:lab_4];
    [lab_4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_3.mas_top);
        make.left.equalTo(lab_2.mas_left);
        make.height.equalTo(lab_1.mas_height);
        make.width.equalTo(lab_1.mas_width);
    }];
    
    _lab_41 = [self createGrayLabel];
    [self.contentView addSubview:_lab_41];
    [_lab_41 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_4.mas_top);
        make.left.equalTo(lab_4.mas_right);
        make.height.equalTo(lab_4.mas_height);
        make.right.equalTo(self.contentView.mas_right);
    }];
}

- (void) setModel:(lz_VideoTemplateModel *)model
{
    //    model = @[@"a",@"b",@"c"];
    _model = model;
    
    _titleLab.text = model.template_name;
    _lab_11.text = model.template_time_long;
    _lab_21.text = model.template_size;
    _lab_31.text = model.template_render_count;
    if ([model.is_charge integerValue] == 0) {
        _lab_41.text = @"免费";
    }else {
        _lab_41.text = model.is_charge;
    }
    [_detailImageView sd_setImageWithURL:[NSURL URLWithString:model.template_picture] placeholderImage:[UIImage imageNamed:@"default_serve_image"] completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        _model.template_image = _detailImageView.image;
    }];
    _detailImageView.contentMode = UIViewContentModeScaleAspectFill;
    _detailImageView.clipsToBounds = YES;
}

+ (CGFloat)cellHeightWithData:(NSString *)data;
{
//    (MainScreenSize.width-3)/2;
    if ([data isEqualToString:@"收费"]) {
        
        return 170;
    }else {
        
        return 170;
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (UILabel *) createGrayLabel
{
    UILabel *lab = [UILabel new];
    lab.textColor = UIColorFromRGB(0x6b6b6b);
    lab.textAlignment = NSTextAlignmentLeft;
    lab.font = [UIFont systemFontOfSize:10];
    return lab;
}

@end
