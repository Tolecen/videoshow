//
//  VedioDetailCell.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VedioDetailCell.h"
#import "lz_VideoTemplateModel.h"

@interface VedioDetailCell ()

@property (nonatomic, strong) UIImageView *detailImageView;

@property (nonatomic, strong) UILabel *lab_11;
@property (nonatomic, strong) UILabel *lab_21;
@property (nonatomic, strong) UILabel *lab_31;
@property (nonatomic, strong) UILabel *lab_41;
@property (nonatomic, strong) UILabel *titleLab;


@end

@implementation VedioDetailCell

+ (instancetype) cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *) reuseIdentifier indexPath:(NSIndexPath *)indexPath;
{
    VedioDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell) {
        cell = [[VedioDetailCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    }
    return cell;
}

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        [self creatView];
    }
    return self;
}

- (void) creatView;
{
    self.detailImageView = [[UIImageView alloc] init];
    self.detailImageView.backgroundColor = [UIColor redColor];
    [self.contentView addSubview:self.detailImageView];
    [self.detailImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(5.5);
        make.top.equalTo(self.contentView.mas_top).offset(12.5);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-8.5);
        make.width.mas_equalTo(126);
    }];
    
    _titleLab = [UILabel new];
    _titleLab.textColor = UIColorFromRGB(0x2e2e2e);
    _titleLab.font = [UIFont systemFontOfSize:12];
    [_titleLab sizeToFit];
    [self.contentView addSubview:_titleLab];
    [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.detailImageView.mas_top).offset(0);
        make.left.equalTo(self.detailImageView.mas_right).offset(8);
    }];
    
    UILabel *lab_1 = [self createGrayLabel];
    lab_1.text = @"模板名称：";
    [lab_1 sizeToFit];
    [self.contentView addSubview:lab_1];
    [lab_1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(_titleLab.mas_bottom).offset(12);
        make.left.equalTo(_titleLab.mas_left).offset(0);
        make.width.mas_equalTo(lab_1.width);
    }];
    
    _lab_11 = [self createGrayLabel];
    [self.contentView addSubview:_lab_11];
    [_lab_11 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_1.mas_top).offset(0);
        make.left.equalTo(lab_1.mas_right).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    
    UILabel *lab_2 = [self createGrayLabel];
    lab_2.text = @"视频时长：";
    [lab_2 sizeToFit];
    [self.contentView addSubview:lab_2];
    [lab_2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_1.mas_bottom).offset(7);
        make.left.equalTo(_titleLab.mas_left).offset(0);
        make.height.equalTo(lab_1.mas_height);
    }];
    
    _lab_21 = [self createGrayLabel];
    [self.contentView addSubview:_lab_21];
    [_lab_21 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_2.mas_top).offset(0);
        make.left.equalTo(lab_2.mas_right).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    
    UILabel *lab_3 = [self createGrayLabel];
    lab_3.text = @"视频大小：";
    [lab_3 sizeToFit];
    [self.contentView addSubview:lab_3];
    [lab_3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_2.mas_bottom).offset(7);
        make.left.equalTo(_titleLab.mas_left).offset(0);
        make.height.equalTo(lab_1.mas_height);
    }];
    
    _lab_31 = [self createGrayLabel];
    [self.contentView addSubview:_lab_31];
    [_lab_31 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_3.mas_top).offset(0);
        make.left.equalTo(lab_3.mas_right).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    
    UILabel *lab_4 = [self createGrayLabel];
    lab_4.text = @"视频状态：";
    [lab_4 sizeToFit];
    [self.contentView addSubview:lab_4];
    [lab_4 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_3.mas_bottom).offset(7);
        make.left.equalTo(_titleLab.mas_left).offset(0);
        make.height.equalTo(lab_1.mas_height);
    }];
    
    _lab_41 = [self createGrayLabel];
    [self.contentView addSubview:_lab_41];
    [_lab_41 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(lab_4.mas_top).offset(0);
        make.left.equalTo(lab_4.mas_right).offset(0);
        make.right.equalTo(self.contentView.mas_right).offset(0);
    }];
    
    UIImageView *deleteImageView = [[UIImageView alloc] init];
    deleteImageView.image = [UIImage imageNamed:@"delete_gray"];
    deleteImageView.userInteractionEnabled = YES;
//    [deleteImageView sizeToFit];
    [self.contentView addSubview:deleteImageView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteCellData:)];
    [deleteImageView addGestureRecognizer:tap];
    [deleteImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(20);
        make.height.mas_equalTo(20);
        make.bottom.equalTo(self.contentView.mas_bottom).offset(-10);
        make.right.equalTo(self.contentView.mas_right).offset(-10);
    }];
}

- (void) setModel:(lz_VideoTemplateModel *)model
{
    //    model = @[@"a",@"b",@"c"];
    _model = model;

    WeakTypeof(weakSelf)
    [self.detailImageView sd_setImageWithURL:[NSURL URLWithString:model.work_picture] placeholderImage:[UIImage imageNamed:@"placeholder_image_2"] options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
        [weakSelf showActivityIndicatorViewWithView:weakSelf.detailImageView stopAnimationHandle:^(UIActivityIndicatorView *testActivityIndicator) {
            if (receivedSize == expectedSize) {
                dispatch_sync(dispatch_get_main_queue(), ^{
                    [testActivityIndicator stopAnimating];
                });
            }
        }];
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    _titleLab.text = model.work_name;// @"守着一份执着"
    _lab_11.text = model.work_name;//@"轻松心情"
    _lab_21.text = model.work_time_long;//@"30秒"
    _lab_31.text = model.work_size;//@"876kb"
    
    self.userInteractionEnabled = NO;
    //0 待处理，1 合成中，2 失败，3 成功合成
    if ([model.make_status integerValue] == 0) {
        _lab_41.text = @"待处理";
    }else if ([model.make_status integerValue] == 1) {
        _lab_41.text = @"合成中，您可以离开本页面进行其他操作";
    }else if ([model.make_status integerValue] == 2) {
        _lab_41.text = @"失败";
    }else if ([model.make_status integerValue] == 3) {
        self.userInteractionEnabled = YES;
        _lab_41.text = @"成功合成";
    }else {
        _lab_41.text = @"情况不详";
    }
    
    _lab_41.textColor = UIColorFromRGB(0xfe6398);
}

+ (CGFloat)cellHeightWithData:(NSString *)data;
{
    return 114;
}

- (void) deleteCellData:(UITapGestureRecognizer *)tap
{
    WeakTypeof(weakSelf)
    if (self.VedioDetailCell_deleteDataBlock) {
        self.VedioDetailCell_deleteDataBlock(weakSelf.model);
    }
}

- (void) layoutSubviews
{
    [super layoutSubviews];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
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
