//
//  MediaPart.h
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaPart : NSObject

/** 索引 */
@property(nonatomic, assign) int index;
/** 视频路径 */
@property(nonatomic, strong) NSString *mediaPath;
/** 音频路径 */
@property(nonatomic, strong) NSString *audioPath;
/** 临时视频路径 */
@property(nonatomic, strong) NSString *tempMediaPath;
/** 临时音频路径 */
@property(nonatomic, strong) NSString *tempAudioPath;
/** 截图路径 */
@property(nonatomic, strong) NSString *thumbPath;
/** 存放导入的视频和图片 */
@property(nonatomic, strong) NSString *tempPath;
/** 导入图片的数量 */
@property(nonatomic, assign) int tempCount;
/** 类型 */
@property(nonatomic, assign) int type;
/** 剪切视频（开始时间） */
@property(nonatomic, assign) int cutStartTime;
/** 剪切视频（结束时间） */
@property(nonatomic, assign) int cutEndTime;
/** 分段长度 */
@property(nonatomic, assign) int duration;
/** 总时长中的具体位置 */
@property(nonatomic, assign) int position;
/** 0.2倍速-3倍速（取值2~30，默认为10） */
@property(nonatomic, assign) int speed;
/** 摄像头 */
@property(nonatomic, assign) int cameraId;
@property(nonatomic, assign) BOOL recording;

@property(nonatomic, assign) double startTime;
@property(nonatomic, assign) double endTime;

- (void)deletePart;

- (int)getDuration;

- (int)getRealDuration;

@end
