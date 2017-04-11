//
//  UIButton+Activity.h
//  Babypai
//
//  Created by ning on 16/4/25.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Activity)

@property (nonatomic, strong, readonly) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign, getter=isWorking) BOOL working;

- (void)setWorking:(BOOL)working;
- (BOOL)isWorking;

@end
