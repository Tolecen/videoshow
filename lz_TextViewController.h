//
//  lz_TextViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^textBlock)(NSDictionary *dict);
@interface lz_TextViewController : BaseViewController

@property (nonatomic, copy) textBlock textBlock;//

@property (nonatomic, copy) NSString *uploadKey;

@end
