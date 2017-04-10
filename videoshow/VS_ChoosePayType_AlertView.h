//
//  VS_ChoosePayType_AlertView.h
//  videoshow
//
//  Created by gutou on 2017/3/29.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^choosePayTypeBlock)(NSInteger index_type);

@interface VS_ChoosePayType_AlertView : UIView

@property (nonatomic, copy) choosePayTypeBlock choosePayTypeBlock;

- (void) setTitleLabText:(NSString *)title;

- (void) show;

@end
