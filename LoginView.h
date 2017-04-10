//
//  LoginView.h
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^loginBlock)(void);
typedef void(^cancelLoginBlock)(void);
@interface LoginView : UIView

@property (nonatomic, copy) loginBlock loginBlock;//
@property (nonatomic, copy) cancelLoginBlock cancelLoginBlock;

@end


