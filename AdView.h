//
//  AdView.h
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AdView;

typedef void(^didSelectAdDetailBlock)(AdView *advertisingview);

typedef void(^leavBlock)(void);//跳过
@interface AdView : UIView

- (void) startplayAdvertisingView:(void (^)(AdView *))advertisingview;

@property (nonatomic, copy) didSelectAdDetailBlock detailBlock;
@property (nonatomic, copy) leavBlock leavBlock;

@end
