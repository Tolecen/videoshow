//
//  BabyTableViewCell.h
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+SDAutoLayout.h"
#import "MacroDefinition.h"

@interface BabyTableViewCell : UITableViewCell

@property(nonatomic, assign)bool isLogin;
@property(nonatomic, assign)long loginUserId;
@property(nonatomic, strong)UserInfomation *loginUserInfomation;

@end
