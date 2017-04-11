//
//  BabyCaptureSessionAssetWriterCoordinator.h
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyCaptureSessionCoordinator.h"

@interface BabyCaptureSessionAssetWriterCoordinator : BabyCaptureSessionCoordinator

- (CGFloat)getTotalVideoDuration;

- (void)deleteLastVideo;//调用delegate
- (void)deleteAllVideo;//不调用delegate

- (NSUInteger)getVideoCount;


- (void)mergeVideoFiles;

@property (nonatomic,assign) int outputHeight;
@property (nonatomic,assign) BOOL isCircle;

@end
