//
//  lz_VideoListTableViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseTableViewController.h"

typedef enum : NSUInteger {
    MyController_CollectionList,
    MyController_WorkList,
    MyController_Other,
} MyController_Type;

//我的作品页面
@interface lz_VideoListTableViewController : BaseTableViewController

@property (nonatomic, assign) MyController_Type MyController_Type;

@end
