//
//  TZSelectedCell.h
//  TZImagePickerController
//
//  Created by ning on 16/5/3.
//  Copyright © 2016年 谭真. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TZAssetModel.h"

@interface TZSelectedCell : UITableViewCell

@property (nonatomic, strong) TZAssetModel *model;

@property (nonatomic, assign)NSInteger cellIndex;

@property (nonatomic, copy) void (^removeSelectedPhotoBlock)();

@end
