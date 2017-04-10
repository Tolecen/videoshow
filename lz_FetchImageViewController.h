//
//  lz_FetchImageViewController.h
//  videoshow
//
//  Created by gutou on 2017/3/20.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseViewController.h"

typedef void(^ImageBlock)(UIImage *image);
typedef void(^ImageDeleteBlock)(void);
typedef void(^returnDataBlock)(NSDictionary *dict);
@interface lz_FetchImageViewController : BaseViewController

@property (nonatomic, strong) UIImage *defaultImage;

@property (nonatomic, copy) ImageBlock ImageBlock;
@property (nonatomic, copy) ImageDeleteBlock ImageDeleteBlock;
@property (nonatomic, copy) returnDataBlock returnDataBlock;

//@property (nonatomic, copy) NSString *uploadKey;
@property (nonatomic, strong) NSDictionary *uploadDict;
@property (nonatomic, assign) NSInteger ImageTag;

@end
