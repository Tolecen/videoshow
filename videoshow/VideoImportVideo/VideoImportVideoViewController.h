//
//  VideoImportVideoViewController.h
//  Babypai
//
//  Created by ning on 16/5/18.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyBaseVC.h"
#import "BaseViewController.h"
@interface VideoImportVideoViewController : BaseViewController

@property(nonatomic, assign) long tag_id;
@property(nonatomic, strong) NSString *tag;

@property(nonatomic, strong) NSURL *videoPath;

@property (nonatomic,assign)NSInteger fromWhich;

@property(nonatomic, copy) void(^onPublish) (NSString * filePath);

@end
