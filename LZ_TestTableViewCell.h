//
//  LZ_TestTableViewCell.h
//  AVFoundation_Test
//
//  Created by gutou on 2017/3/12.
//  Copyright © 2017年 gutou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^PlayCellBlock)(NSInteger TypeIndex);


/**
 * The style of cell cannot stop in screen center.
 * 播放滑动不可及cell的类型
 */
typedef NS_OPTIONS(NSInteger, JPPlayUnreachCellStyle) {
    JPPlayUnreachCellStyleNone = 1 << 0,  // normal 播放滑动可及cell
    JPPlayUnreachCellStyleUp = 1 << 1,    // top 顶部不可及
    JPPlayUnreachCellStyleDown = 1<< 2    // bottom 底部不可及
};

@interface LZ_TestTableViewCell : UITableViewCell

+ (instancetype) cellWithTableView:(UITableView *)tableView reuseIdentifier:(NSString *) reuseIdentifier indexPath:(NSIndexPath *)indexPath;

@property (nonatomic, strong) NSArray *model;

+ (CGFloat)cellHeightWithData:(NSString *)data;

@property (nonatomic, copy) PlayCellBlock PlayCellBlock;


@property (strong, nonatomic) UIImageView *videoImv;

/** videoPath */
@property(nonatomic, strong)NSString *videoPath;

/** indexPath */
@property(nonatomic, strong)NSIndexPath *indexPath;

/** cell类型 */
@property(nonatomic, assign)JPPlayUnreachCellStyle cellStyle;

@end
