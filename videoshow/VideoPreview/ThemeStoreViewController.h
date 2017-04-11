//
//  ThemeStoreViewController.h
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyBaseVC.h"

@interface ThemeStoreViewController : BabyBaseVC

/**
 *  通知视频编辑页重新加载Theme
 */
@property(nonatomic, copy) void(^onThemeDownload) ();

@end
