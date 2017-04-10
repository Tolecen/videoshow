//
//  lz_videoCategoryScroll.h
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol lz_videoDelegate <NSObject>

- (void) lz_videoDidselect:(UIButton *)btn;

@end

@interface lz_videoCategoryScroll : UIScrollView

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, weak) id<lz_videoDelegate> lz_videoDelegate;

- (void) setSelectBtn:(NSInteger)index;

@end
