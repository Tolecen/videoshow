//
//  LZ_TableViewController.h
//  AVFoundation_Test
//
//  Created by gutou on 2017/3/12.
//  Copyright © 2017年 gutou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"

typedef void(^lz_OnlineVideoBlock)(NSInteger typeIndex);
@interface LZ_TableViewController : BaseTableViewController

@property (nonatomic, copy) lz_OnlineVideoBlock lz_OnlineVideoBlock;

- (void) allPause;

- (void) allPlay;

@end
