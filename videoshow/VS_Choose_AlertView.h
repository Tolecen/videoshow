//
//  VS_Choose_AlertView.h
//  videoshow
//
//  Created by gutou on 2017/3/20.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    WaterMarkType_PicWaterMark,
    WaterMarkType_TextWaterMark,
    WaterMarkType_OtherWaterMark,
} WaterMarkType;

typedef void(^chooseBlock)(WaterMarkType WaterMarkType);

@interface VS_Choose_AlertView : UIView

@property (nonatomic, copy) chooseBlock block;

- (void) setTitles:(NSArray *)titles;

- (void) show;

@end
