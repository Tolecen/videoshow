//
//  BabyMediaControl.h
//  Babypai
//
//  Created by ning on 16/5/9.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IJKMediaPlayback;

@interface BabyMediaControl : UIControl

- (void)showNoFade;
- (void)showAndFade;
- (void)hide;
- (void)hideAndRefresh;
- (void)refreshMediaControl;

- (void)beginDragMediaSlider;
- (void)endDragMediaSlider;
- (void)continueDragMediaSlider;

- (void)showLoading:(BOOL)isLoading;

@property(nonatomic,weak) id<IJKMediaPlayback> delegatePlayer;

@end
