//
//  VS_AlertVC_Logout.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VS_AlertVC_Logout_Block)(UIButton *btn);

@interface VS_AlertVC_Logout : UIView

@property (nonatomic, copy) VS_AlertVC_Logout_Block block;

- (void) show;

@end
