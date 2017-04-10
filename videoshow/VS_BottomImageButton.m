//
//  BottomImageButton.m
//  videoshow
//
//  Created by gutou on 2017/3/1.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "VS_BottomImageButton.h"

@implementation VS_BottomImageButton

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        frame.size = CGSizeMake(MainScreenSize.width/2, 41.5);
        self.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        self.backgroundColor = [UIColor whiteColor];
        
        self.imageEdgeInsets = UIEdgeInsetsMake(38, 0, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -MainScreenSize.width/2, -3.5, 0);
                
        [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIImage *btn_1_image = [AppTool createImageFromColor:[AppAppearance sharedAppearance].mainColor withRect:CGRectMake(0, 0, MainScreenSize.width/2, 3.5)];
        [self setImage:btn_1_image forState:UIControlStateSelected];
        
        UIImage *btn_1_image_normal = [AppTool createImageFromColor:[UIColor clearColor] withRect:CGRectMake(0, 0, MainScreenSize.width/2, 3.5)];
        [self setImage:btn_1_image_normal forState:UIControlStateNormal];
    }
    return self;
}

- (void) setHighlighted:(BOOL)highlighted
{
    
}


@end
