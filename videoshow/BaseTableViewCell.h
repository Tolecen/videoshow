//
//  BaseTableViewCell.h
//  videoshow
//
//  Created by gutou on 2017/4/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseTableViewCell : UITableViewCell


//系统小菊花
- (void) showActivityIndicatorViewWithView:(id)view
                       stopAnimationHandle:(void (^)(UIActivityIndicatorView *testActivityIndicator))animationHandle;

@end
