//
//  lz_videoListPageViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^didSelectBlock_2)(NSDictionary *dict);
typedef void(^pageScrollBlock)(NSInteger index);//滑动page时传递出index
@interface lz_videoListPageViewController : UIViewController

@property (nonatomic, strong) NSArray *datas;

@property (nonatomic, copy) didSelectBlock_2 didSelectBlock;

- (void) setCurrentViewController:(NSUInteger)index;

@property (nonatomic, copy) pageScrollBlock pageScrollBlock;

@end
