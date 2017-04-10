//
//  lz_UserCenterTopPic.m
//  videoshow
//
//  Created by gutou on 2017/3/6.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_UserCenterTopPic.h"
#import "UIImageView+YYImageBrowser.h"
#import "UserModel.h"

//height.scale 0.28

#define Height_Scale 0.28

@interface lz_UserCenterTopPic ()

@property (nonatomic, strong) UIImageView *userImageView;
@property (nonatomic, strong) UILabel *userNameLab;
@property (nonatomic, strong) UIImageView *userTagImageView;

@end

@implementation lz_UserCenterTopPic

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.frame = CGRectMake(0, 0, MainScreenSize.width, MainScreenSize.height * Height_Scale);
//        self.backgroundColor = [AppAppearance sharedAppearance].mainColor;
        self.userInteractionEnabled = YES;
        [self setupView];
    }
    return self;
}

- (void) setupView
{
    UIImageView *backimageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_infoBackground"]];
    backimageview.frame = CGRectMake(0, 0, MainScreenSize.width, self.height);
    [self addSubview:backimageview];
    
    self.userImageView = [[UIImageView alloc] init];
    self.userImageView.frame = CGRectMake(30, 0, self.frame.size.height / 3.1, self.frame.size.height / 3.1);
    self.userImageView.center = CGPointMake(self.userImageView.center.x, self.frame.size.height/2);
    self.userImageView.layer.cornerRadius = self.userImageView.size.height / 2;
    self.userImageView.layer.masksToBounds = YES;
    self.userImageView.userInteractionEnabled = YES;
    self.userImageView.image = [UIImage imageNamed:@"placeholder_image_2"];
    self.userImageView.backgroundColor = [UIColor whiteColor];
    [self.userImageView setBrowseEnabled:YES];
    [self addSubview:self.userImageView];
    
    self.userNameLab = [UILabel new];
    self.userNameLab.font = [UIFont systemFontOfSize:15];
    self.userNameLab.frame = CGRectMake(self.userImageView.right + 10, self.userImageView.center.y-10, 100, 30);
    self.userNameLab.text = @"昵称";
    self.userNameLab.textColor = [UIColor whiteColor];
    [self addSubview:self.userNameLab];
    
    self.userTagImageView = [[UIImageView alloc] init];
    self.userTagImageView.frame = CGRectMake(self.userNameLab.left, self.userNameLab.bottom, 10, 10);
    [self addSubview:self.userTagImageView];
}


- (void) setDatas:(UserModel *)datas
{
    _datas = datas;
    if (datas.image_url.length) {
        [self.userImageView sd_setImageWithURL:[NSURL URLWithString:datas.image_url]];
    }
    
    if (datas.nickname.length) {
        [[AppDataManager defaultManager] setName:datas.nickname];
    }
    if (self.userImageView.image) {
        [[AppDataManager defaultManager] setUser_image:UIImagePNGRepresentation(self.userImageView.image)];
    }
    
    self.userNameLab.text = datas.nickname;
    [self.userNameLab sizeToFit];
    
    self.userTagImageView.image = nil;
    [self.userTagImageView sizeToFit];
    
    
//    [self.userNameLab mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.userTagImageView.mas_right).offset(0);
//        make.centerY.equalTo(self.userTagImageView.mas_centerY);
//    }];
//    
//    [self.userTagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(self.userNameLab.mas_bottom);
//        make.left.equalTo(self.userNameLab.mas_left);
//    }];
}

@end
