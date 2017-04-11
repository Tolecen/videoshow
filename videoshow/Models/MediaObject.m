//
//  MediaObject.m
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "MediaObject.h"
#import "StringUtils.h"
#import "BabyFileManager.h"

@implementation MediaObject

+ (instancetype)initWithKey:(NSString *)key path:(NSString *)path
{
    MediaObject *object = [[self alloc]init];
    
    object.mKey = key;
    object.mOutputDirectory = path;
    object.mVideoBitrate = DEFAULT_VIDEO_BITRATE;
    object.mOutputObjectPath = [[path stringByAppendingPathComponent:key] stringByAppendingString:@".txt"];
    object.mOutputVideoPath = [path stringByAppendingString:@".mp4"];
    object.mOutputVideoThumbPath = [path stringByAppendingString:@".jpg"];
    object.mMaxDuration = DEFAULT_MAX_DURATION;
    object.mMinDuration = DEFAULT_MIN_DURATION;
    object.mMediaList = [[NSMutableArray alloc]init];
    return object;
}

- (MediaPart *)buildMediaPart:(int)cameraId
{
    
    MediaPart *part = [[MediaPart alloc]init];
    part.position = [self getDuration];
    part.index = (int)self.mMediaList.count;
    part.mediaPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp4"];
    part.audioPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp3"];
    part.thumbPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".jpg"];
    part.cameraId = cameraId;
    part.recording = YES;
    part.startTime = (double) [[NSDate date] timeIntervalSince1970];
    part.type = MEDIA_PART_TYPE_RECORD;
    self.mCurrentPart = part;
    [self.mMediaList addObject:part];
    
    return part;
}

- (MediaPart *)buildMediaPart:(int)cameraId videoSuffix:(NSString *)videoSuffix
{
    DLog(@"(int)self.mMediaList.count : %d", (int)self.mMediaList.count);
    MediaPart *part = [[MediaPart alloc]init];
    part.position = [self getDuration];
    part.index = (int)self.mMediaList.count;
    part.mediaPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:videoSuffix];
    part.tempMediaPath = [self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"crop_%d%@", part.index, videoSuffix]];
    part.audioPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp3"];
    part.thumbPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".jpg"];
    part.cameraId = cameraId;
    part.recording = YES;
    part.startTime = (double) [[NSDate date] timeIntervalSince1970]*1000;
    part.type = MEDIA_PART_TYPE_RECORD;
    [self.mMediaList addObject:part];
    self.mCurrentPart = part;
    DLog(@"part.mediaPath : %@", part.mediaPath);
    return part;
}

- (MediaPart *)buildMediaPart:(NSString *)path duration:(int)duration type:(int)type
{
    MediaPart *part = [[MediaPart alloc]init];
    part.position = [self getDuration];
    part.index = (int)self.mMediaList.count;
    part.mediaPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp4"];
    part.tempMediaPath = [self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"crop_%d%@", part.index, @".mp4"]];
    part.audioPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp3"];
    part.thumbPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".jpg"];
    part.recording = NO;
    part.duration = duration;
    part.startTime = 0;
    part.endTime = duration;
    part.cutStartTime = 0;
    part.cutEndTime = duration;
    part.tempPath = path;
    part.type = type;
    self.mCurrentPart = part;
    [self.mMediaList addObject:part];
    
    return part;
}

- (MediaPart *)buildMediaPart:(NSString *)path duration:(int)duration type:(int)type tempCount:(int)tempCount
{
    MediaPart *part = [[MediaPart alloc]init];
    part.position = [self getDuration];
    part.index = (int)self.mMediaList.count;
    part.mediaPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp4"];
    part.tempMediaPath = [self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"crop_%d%@", part.index, @".mp4"]];
    part.audioPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".mp3"];
    part.thumbPath = [[self.mOutputDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", part.index]] stringByAppendingString:@".jpg"];
    part.recording = NO;
    part.duration = duration;
    part.startTime = 0;
    part.endTime = duration;
    part.cutStartTime = 0;
    part.cutEndTime = duration;
    part.tempPath = path;
    part.tempCount = tempCount;
    part.type = type;
    [self.mMediaList addObject:part];
    
    return part;
}

+ (NSDictionary *)mj_objectClassInArray
{
    return @{ @"mMediaList" : [MediaPart class] };
}

- (NSMutableArray *)getConcatYUVArrayMediaPath
{
    if (self.mMediaList == nil) {
        return nil;
    }
    
    NSMutableArray *medias = [[NSMutableArray alloc]init];
    
    for (MediaPart *part in self.mMediaList) {
        if ([part getRealDuration] == 0) {
            continue;
        }
        [medias addObject:part.mediaPath];
    }
    
    return medias;
}

- (NSString *)getConcatYUV
{
    if (self.mMediaList == nil) {
        return nil;
    }
    
    NSString *yuv = @"";
    
    for (int i = 0, j = (int)self.mMediaList.count; i < j; i++) {
        MediaPart *part = [self.mMediaList objectAtIndex:i];
        yuv = [yuv stringByAppendingString:[NSString stringWithFormat:@"file %@", part.mediaPath]];
        if (i+1 < j) {
            yuv = [yuv stringByAppendingString:@"\n"];
        }
    }
    DLog(@"getConcatYUV : %@", yuv);
    return yuv;
}

- (MediaPart *)getCurrentPart
{
    if (self.mCurrentPart != nil) {
        return self.mCurrentPart;
    }
    
    if (self.mMediaList != nil && self.mMediaList.count > 0) {
        self.mCurrentPart = [self.mMediaList objectAtIndex:(self.mMediaList.count - 1)];
    }
    return self.mCurrentPart;
}

- (int)getCurrentIndex
{
    MediaPart *part = [self getCurrentPart];
    if (part != nil) {
        return part.index;
    }
    return 0;
}

- (MediaPart *)getPart:(int)index
{
    if (self.mMediaList != nil && index < self.mMediaList.count) {
        return [self.mMediaList objectAtIndex:index];
    }
    
    return nil;
}

- (NSString *)getOutputTempVideoPath
{
    return [[self.mOutputDirectory stringByAppendingPathComponent:self.mKey] stringByAppendingString:@".mp4"];
}

- (NSString *)getObjectFilePath
{
    if ([StringUtils isEmpty:self.mOutputObjectPath]) {
        return [[self.mOutputDirectory stringByAppendingPathComponent:[self.mOutputDirectory lastPathComponent]] stringByAppendingString:@".txt"];
    }
    return self.mOutputObjectPath;
}

- (int)getDuration
{
    int duration = 0;
    if (self.mMediaList != nil) {
        for (MediaPart *part in self.mMediaList) {
            duration += [part getDuration];
        }
    }
    return duration;
}

- (int)getRealDuration
{
    int duration = 0;
    
    if (self.mMediaList != nil) {
        for (MediaPart *part in self.mMediaList) {
            duration += [part getRealDuration];
        }
    }
    
    return duration;
}

- (void)removePart:(MediaPart *)part deleteData:(BOOL)deleteData
{
    
    if (part != nil) {
        if (deleteData) {
            [part deletePart];
        }
        if (self.mMediaList != nil) {
            [self.mMediaList removeObject:part];
        }
    }
    if (part == self.mCurrentPart) {
        self.mCurrentPart = nil;
    }
}

- (void)deleteObject
{
    [[BabyFileManager manager] deleteFile:self.mOutputDirectory];
}

@end
