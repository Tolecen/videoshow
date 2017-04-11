//
//  MediaPart.m
//  Babypai
//
//  Created by ning on 16/5/4.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "MediaPart.h"
#import "BabyFileManager.h"

@implementation MediaPart

- (void)deletePart
{
    [[BabyFileManager manager] deleteFile:self.mediaPath];
    [[BabyFileManager manager] deleteFile:self.audioPath];
    [[BabyFileManager manager] deleteFile:self.thumbPath];
    [[BabyFileManager manager] deleteFile:self.tempMediaPath];
    [[BabyFileManager manager] deleteFile:self.tempAudioPath];
}

- (int)getDuration
{
    double now = [[NSDate date] timeIntervalSince1970]*1000;
    int dur = (int) (now - self.startTime);
    return self.duration > 0 ? self.duration : dur;
}

- (int)getRealDuration
{
    return self.duration > 0 ? self.duration : 0;
}

@end
