//
//  lz_videoCategoryScroll.m
//  videoshow
//
//  Created by gutou on 2017/3/9.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_videoCategoryScroll.h"
#import "lz_VideoTemplateModel.h"

@interface lz_videoCategoryScroll ()

@property (nonatomic, strong) NSMutableArray *categoryBtnStates;//记录btn点击状态

@end

@implementation lz_videoCategoryScroll

- (instancetype) initWithFrame:(CGRect)frame
{
    if ([super initWithFrame:frame]) {
        
        self.userInteractionEnabled = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.bounces = NO;
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}


- (void) setDatas:(NSArray *)datas
{
    _datas = datas;
    
    self.contentSize = CGSizeMake(datas.count * MainScreenSize.width/6, self.height);
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    self.categoryBtnStates = [NSMutableArray array];
    
    [datas enumerateObjectsUsingBlock:^(lz_VideoTemplateModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor whiteColor];
        
        if (idx == 0) {
            [btn setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
        }else {
            [btn setTitleColor:UIColorFromRGB(0x868585) forState:UIControlStateNormal];
        }
        
        btn.titleLabel.font = [UIFont systemFontOfSize:13];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        [btn setTitle:obj.style_name forState:UIControlStateNormal];
        btn.frame = CGRectMake(0 + idx * MainScreenSize.width/6, 0, MainScreenSize.width/6, self.self.height);
        btn.tag = idx + 300;
        [btn addTarget:self action:@selector(Click:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        [self.categoryBtnStates addObject:btn];
    }];
}

- (void) Click:(UIButton *)btn
{
    [self changeBtnStatusWithBtn:btn];
    
    if ([_lz_videoDelegate respondsToSelector:@selector(lz_videoDidselect:)]) {
        [_lz_videoDelegate lz_videoDidselect:btn];
    }
}

//从外部更改btn状态
- (void) setSelectBtn:(NSInteger)index;
{
    UIButton *btn = [self viewWithTag:index+300];
    [self changeBtnStatusWithBtn:btn];
}

- (void) changeBtnStatusWithBtn:(UIButton *)btn
{
    [self.categoryBtnStates enumerateObjectsUsingBlock:^(UIButton * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (idx == btn.tag-300) {
            [obj setTitleColor:[AppAppearance sharedAppearance].mainColor forState:UIControlStateNormal];
            if (obj.frame.origin.x >= MainScreenSize.width) {
                [self setContentOffset:CGPointMake(obj.frame.origin.x-MainScreenSize.width+MainScreenSize.width/6, 0) animated:YES];
            }else if (obj.frame.origin.x <= 0) {
                [self setContentOffset:CGPointMake(0, 0) animated:YES];
            }else{
                
            }
        }else {
            [obj setTitleColor:UIColorFromRGB(0x868585) forState:UIControlStateNormal];
        }
    }];
}

@end
