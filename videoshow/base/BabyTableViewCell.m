//
//  BabyTableViewCell.m
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyTableViewCell.h"
#import "MacroDefinition.h"

@implementation BabyTableViewCell

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        [self initUserInfo];
    }
    
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)initUserInfo
{
    
    _loginUserInfomation = [Utils userInfomation];
    
    if (_loginUserInfomation != nil) {
        _loginUserId = _loginUserInfomation.info.user_id;
        _isLogin = _loginUserId > 0;
        
    } else {
        _isLogin = NO;
        _loginUserId = 0;
    }
    
}

@end
