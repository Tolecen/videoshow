//
//  Utils.m
//  Babypai
//
//  Created by ning on 15/4/9.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import "Utils.h"
#import "SFHFKeychainUtils.h"
#import "MJExtension.h"


@implementation Utils

+ (instancetype)utils {
    static Utils *utils;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        utils = [[self alloc] init];
    });
    return utils;
}

#pragma mark 根据要显示的text计算label高度
+ (CGFloat)contentCellHeightWithText:(NSString*)text contentWidth:(int)width fontSize:(UIFont *)font
{
    NSInteger ch;
    //设置字体
    CGSize size = CGSizeMake(width, MAXFLOAT);//注：这个宽 是你要显示的宽度既固定的宽度，高度可以依照自己的需求而定
    NSDictionary * tdic = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
    size =[text boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:tdic context:nil].size;
    ch = size.height + 1.0f;
    return ch;
    
}

// 心跳动画
+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration
{
    [self heartbeatView:view duration:fDuration maxSize:1.1f durationPerBeat:0.5f];
}
+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat
{
    if (view && (fDurationPerBeat > 0.1f))
    {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
        
        CATransform3D scale1 = CATransform3DMakeScale(0.8, 0.8, 1);
        CATransform3D scale2 = CATransform3DMakeScale(fMaxSize, fMaxSize, 1);
        CATransform3D scale3 = CATransform3DMakeScale(fMaxSize - 0.3f, fMaxSize - 0.3f, 1);
        CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
        
        NSArray *frameValues = [NSArray arrayWithObjects:
                                [NSValue valueWithCATransform3D:scale1],
                                [NSValue valueWithCATransform3D:scale2],
                                [NSValue valueWithCATransform3D:scale3],
                                [NSValue valueWithCATransform3D:scale4],
                                nil];
        
        [animation setValues:frameValues];
        
        NSArray *frameTimes = [NSArray arrayWithObjects:
                               [NSNumber numberWithFloat:0.05],
                               [NSNumber numberWithFloat:0.2],
                               [NSNumber numberWithFloat:0.6],
                               [NSNumber numberWithFloat:1.0],
                               nil];
        [animation setKeyTimes:frameTimes];
        
        animation.fillMode = kCAFillModeForwards;
        animation.duration = fDurationPerBeat;
        animation.repeatCount = fDuration/fDurationPerBeat;
        
        [view.layer addAnimation:animation forKey:@"heartbeatView"];
    }else{}
    
}

// 视图抖动动画
+ (void)shakeView:(UIView *)view duration:(CGFloat)fDuration
{
    if (view && (fDuration >= 0.1f))
    {
        CABasicAnimation* shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        //设置抖动幅度
        shake.fromValue = [NSNumber numberWithFloat:-0.3];
        shake.toValue = [NSNumber numberWithFloat:+0.3];
        shake.duration = 0.1f;
        shake.repeatCount = fDuration/4/0.1f;
        shake.autoreverses = YES;
        [view.layer addAnimation:shake forKey:@"shakeView"];
    }else{}
    
}


-(NSDateFormatter *)dateFormatter
{
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd' 'HH:mm"];
    return dateFormatter;
}
// 时间转换为时间戳
- (NSString*)timeTransformationTimestamp:(NSString*)dataStr
{
    NSDateFormatter *formatter = [self dateFormatter];
    NSDate* date = [formatter dateFromString:dataStr];
    
    return [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]];
}

+ (NSString *)friendTime:(long)message
{
    NSString* time;
    NSCalendar* calendar= [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit;
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"Asia/Shanghai"]];
    [dateFormatter setDateFormat:@"MM-dd' 'HH:mm"];
    NSDate* createdAt = [NSDate dateWithTimeIntervalSince1970:message];
    NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *createdAtComponents = [calendar components:unitFlags fromDate:createdAt];
    if([nowComponents year] == [createdAtComponents year] &&
       [nowComponents month] == [createdAtComponents month] &&
       [nowComponents day] == [createdAtComponents day])
    {//今天
        
        int time_long = [createdAt timeIntervalSinceNow];
        
        if (time_long <= 0 && time_long >-60*60) {//一小时之内
            int min = -time_long/60;
            if (min == 0) {
                min = 1;
            }
            //            time = [[NSString alloc]initWithFormat:loadMuLanguage(@"%d分钟前",@""),min];
            if (min <= 1) {
                time = [NSString stringWithFormat:@" %d分钟前",min];
            } else {
                time = [NSString stringWithFormat:@"%d分钟前",min];
            }
        }else if (time_long > 0) {
            time = [NSString stringWithFormat:@" %d分钟前",1];
            
        } else {
            [dateFormatter setDateFormat:@"'今天 'HH:mm"];
            
            time = [dateFormatter stringFromDate:createdAt];
        }
    } else if ([nowComponents year] == [createdAtComponents year]) {
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"MM-dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    } else {//去年
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"YYYY-MM-dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    }
    
    return time;
}

+ (NSString *)dataTOjsonString:(id)object
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

+ (void)updataUserInfoDic:(UserInfomation *)userInfo
{
    NSDictionary *userInfoDict = userInfo.mj_keyValues;
    NSString *userInfoStr = [self dataTOjsonString:userInfoDict];
    
    [SFHFKeychainUtils storeUsername:DEFAULT_USER andPassword:userInfoStr forServiceName:APPNAME updateExisting:YES error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER object:nil];
}

+ (void)updataUserInfo:(NSString *)userInfo
{
    [SFHFKeychainUtils storeUsername:DEFAULT_USER andPassword:userInfo forServiceName:APPNAME updateExisting:YES error:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_USER object:nil];
}

+ (long)userId
{
    long uid = 0;
    
    UserInfomation *userInfo = [self userInfomation];
    
    if (userInfo != nil) {
        uid = userInfo.info.user_id;
    }
    
    return uid;
}

+ (UserInfomation *)userInfomation
{
    UserInfomation *userInfomation = nil;
    NSString *data = [SFHFKeychainUtils getPasswordForUsername:DEFAULT_USER andServiceName:APPNAME error:nil];
    if (data != nil) {
        userInfomation = [UserInfomation mj_objectWithKeyValues:data];
    }
    
    return userInfomation;
}

+ (void)setUserDefault:(NSString *)data nameWith:(NSString *)name
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:name];
}


+ (NSString *)getUserDefaultStringWithName:(NSString *)name
{
    NSUserDefaults *defaults =[NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:name];
}

+ (NSDictionary *)getUserDefaultWithName:(NSString *)name
{
    NSDictionary *dic = nil;
    NSString *data = [self getUserDefaultStringWithName:name];
    if (data != nil) {
        dic = [NSJSONSerialization JSONObjectWithData:[data dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingAllowFragments error:nil];
    }
    return dic;
}


+ (NSString *)getImagePath:(BabyFile *)file tagWith:(NSString *)tag
{
    if(nil != file) {
        if(tag == nil)
            tag = @"_fw554";
        return [NSString stringWithFormat:@"%@%@%@", file.host, file.key, tag];
    }
    
    return nil;
}

+ (NSURL *)getImagePathURL:(BabyFile *)file tagWith:(NSString *)tag
{
    
    return [NSURL URLWithString:[self getImagePath:file tagWith:tag]];
}

+ (NSString *)getVideoPath:(BabyFile *)file
{
    if(nil != file) {
        return [NSString stringWithFormat:@"%@video/%@", file.host, file.key];
    }
    return nil;
}

+ (NSString *)urlJiexi:(NSString *)key webAddress:(NSString *)webAddress
{
    NSError *error;
    NSString *regTags=[[NSString alloc] initWithFormat:@"(^|&|\\?)+%@=+([^&]*)(&|$)",key];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regTags
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    // 执行匹配的过程
    // NSString *webaddress=@"http://www.baidu.com/dd/adb.htm?adc=e12&xx=lkw&dalsjd=12";
    NSArray *matches = [regex matchesInString:webAddress
                                      options:0
                                        range:NSMakeRange(0, [webAddress length])];
    for (NSTextCheckingResult *match in matches) {
        //NSRange matchRange = [match range];
        //NSString *tagString = [webaddress substringWithRange:matchRange];  // 整个匹配串
        //        NSRange r1 = [match rangeAtIndex:1];
        //        if (!NSEqualRanges(r1, NSMakeRange(NSNotFound, 0))) {    // 由时分组1可能没有找到相应的匹配，用这种办法来判断
        //            //NSString *tagName = [webaddress substringWithRange:r1];  // 分组1所对应的串
        //            return @"";
        //        }
        
        NSString *tagValue = [webAddress substringWithRange:[match rangeAtIndex:2]];  // 分组2所对应的串
        //    NSLog(@"分组2所对应的串:%@\n",tagValue);
        return tagValue;
    }
    return @"";
}

+ (NSString *)urlScheme:(NSString *)parten resourceSpecifier:(NSString *)resourceSpecifier
{
    NSError* error = nil;
    NSString *march = nil;
    NSRegularExpression *reg = [NSRegularExpression regularExpressionWithPattern:parten options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* match = [reg matchesInString:resourceSpecifier options:NSMatchingReportCompletion range:NSMakeRange(0, [resourceSpecifier length])];
    
    if (match.count != 0)
    {
        for (NSTextCheckingResult *matc in match)
        {
            NSRange firstHalfRange = [matc rangeAtIndex:1];
            march = [resourceSpecifier substringWithRange:firstHalfRange];
        }
    }
    return march;
}

- (BOOL)isFileExists:(NSString *)filePath
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    return [file_manager fileExistsAtPath:filePath];
}

- (void)getImageFromPHAsset:(PHAsset *)asset Complete:(ResultPath)result {
    __block NSData *data;
    PHAssetResource *resource = [[PHAssetResource assetResourcesForAsset:asset] firstObject];
    
    __block NSString *filePath = nil;
    
    if (asset.mediaType == PHAssetMediaTypeImage) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        options.synchronous = YES;
        [[PHImageManager defaultManager] requestImageDataForAsset:asset
                                                          options:options
                                                    resultHandler:
         ^(NSData *imageData,
           NSString *dataUTI,
           UIImageOrientation orientation,
           NSDictionary *info) {
             data = [NSData dataWithData:imageData];
             filePath = [info valueForKey:@"PHImageFileURLKey"];
             NSLog(@"PHImageFileURLKey : %@", [info valueForKey:@"PHImageFileURLKey"]);
         }];
    }
    
    if (result) {
        if (data.length <= 0) {
            result(nil, nil);
        } else {
            result(filePath, resource.originalFilename);
        }
    }
}

- (void)getFileFromPHAsset:(PHAsset *)asset Complete:(ResultPath)result {
    NSArray *assetResources = [PHAssetResource assetResourcesForAsset:asset];
    PHAssetResource *resource;
    
    for (PHAssetResource *assetRes in assetResources) {
//        if (assetRes.type == PHAssetResourceTypePairedVideo ||
//            assetRes.type == PHAssetResourceTypeVideo) {
//            resource = assetRes;
//        }
        resource = assetRes;
    }
    NSString *fileName = @"tempFile";
    if (resource.originalFilename) {
        fileName = resource.originalFilename;
    } else {
        if (resource.type == PHAssetResourceTypePairedVideo || resource.type == PHAssetResourceTypeVideo) {
            fileName = @"tempFile.mp4";
        } else {
            fileName = @"tempFile.jpg";
        }
    }
    
//    if (asset.mediaType == PHAssetMediaTypeVideo || asset.mediaSubtypes == PHAssetMediaSubtypePhotoLive) {
        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
        options.version = PHImageRequestOptionsVersionCurrent;
        options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
        
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        [[PHAssetResourceManager defaultManager] writeDataForAssetResource:resource
                                                                    toFile:[NSURL fileURLWithPath:PATH_MOVIE_FILE]
                                                                   options:nil
                                                         completionHandler:^(NSError * _Nullable error) {
                                                             if (error) {
                                                                 result(nil, nil);
                                                             } else {
                                                                 result(PATH_MOVIE_FILE, fileName);
                                                             }
                                                         }];
//    } else {
//        result(nil, nil);
//    }
}

//http://stackoverflow.com/questions/22680296/how-to-save-hd-image-in-from-alasset-to-documents-folder-in-ios
- (void)getVideoFromALAsset:(ALAsset *)asset Complete:(ResultPath)result {
    
    ALAssetRepresentation *representation = asset.defaultRepresentation;
    
//    long long size = representation.size;
//    NSMutableData* data = [[NSMutableData alloc] initWithCapacity:size];
//    void* buffer = [data mutableBytes];
//    [representation getBytes:buffer fromOffset:0 length:size error:nil];
//    NSData *fileData = [[NSData alloc] initWithBytes:buffer length:size];
//    NSString *fileName = representation.filename;
//    NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
//    
//    [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)   {
//        [fileData writeToFile:PATH_MOVIE_FILE atomically:NO];
//        
//    });
    

    
    long long sizeOfRawDataInBytes = representation.size;
    NSMutableData* rawData = [[NSMutableData alloc]initWithCapacity:sizeOfRawDataInBytes];
    void* bufferPointer = [rawData mutableBytes];
    NSError* error=nil;
    [representation getBytes:bufferPointer fromOffset:0 length:sizeOfRawDataInBytes error:&error];
    if (error) {
        NSLog(@"Getting bytes failed with error: %@",error);
    }
    else {
        NSString *fileName = representation.filename;
        NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        
        [[NSFileManager defaultManager] removeItemAtPath:PATH_MOVIE_FILE error:nil];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void)   {
            [rawData writeToFile:PATH_MOVIE_FILE atomically:NO];
            
        });
    }
    
}

- (void)copyFileFromAsset:(id)asset Complete:(ResultPath)result
{
    if ([asset isKindOfClass:[PHAsset class]]) {
        [self getFileFromPHAsset:asset Complete:result];
    } else if ([asset isKindOfClass:[ALAsset class]]) {
        [self getFileFromALAsset:asset Complete:result];
    }

}

//http://stackoverflow.com/questions/8791049/get-video-nsdata-from-alasset-url-ios
- (void) getFileFromALAsset:(ALAsset*)asset Complete:(ResultPath)result
{
    
    ALAssetRepresentation *rep = [asset defaultRepresentation];
    NSString *fileName = rep.filename;
    NSString *PATH_MOVIE_FILE = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
    
    [[NSFileManager defaultManager] createFileAtPath:PATH_MOVIE_FILE contents:nil attributes:nil];
    NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:PATH_MOVIE_FILE];
    if (!handle) {
        result(nil, nil);
    }
    
    static const NSUInteger BufferSize = 1024*1024;
    
    
    uint8_t *buffer = calloc(BufferSize, sizeof(*buffer));
    NSUInteger offset = 0, bytesRead = 0;
    
    do {
        @try {
            bytesRead = [rep getBytes:buffer fromOffset:offset length:BufferSize error:nil];
            [handle writeData:[NSData dataWithBytesNoCopy:buffer length:bytesRead freeWhenDone:NO]];
            offset += bytesRead;
        } @catch (NSException *exception) {
            free(buffer);
            
            result(nil, nil);
        }
    } while (bytesRead > 0);
    
    free(buffer);
    result(PATH_MOVIE_FILE, fileName);
}

- (BOOL)canAutoPlay:(BOOL)isNetworkWAN
{
    BOOL setting_autoPlayMp4 = NO;
    
    NSString *autoPlay = [Utils getUserDefaultStringWithName:DEFAULT_SETTING_AUTOPLAY];
    
    if (![autoPlay isEqualToString:@"NO"] && !isNetworkWAN) {
        setting_autoPlayMp4 = YES;
    }
    
    return setting_autoPlayMp4;
}

@end
