//
//  CellThemeStore.h
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyTableViewCell.h"
#import "VideoTheme.h"

@interface CellThemeStore : BabyTableViewCell

@property(nonatomic, strong) VideoTheme *mVideoTheme;

@property(nonatomic, assign) NSInteger cellIndex;

@property(nonatomic, copy) void(^downloadClicked)(NSInteger cellIndex, VideoTheme *mVideoTheme);

@end
