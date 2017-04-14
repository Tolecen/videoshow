//
//  BabyFileManager.m
//  Babypai
//
//  Created by ning on 16/4/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyFileManager.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "ImageUtils.h"

@implementation BabyFileManager

+ (instancetype)manager
{
    static BabyFileManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (void)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            DLogE(@"error removing file: %@", [error localizedDescription]);
        }
    }
}

- (void)deleteUploadEntity:(BabyUploadEntity *)uploadEntity  withCompletion:(OnDeleteCompletionBlock)completionBlock
{
    NSString *dir = [[self getCurrentDocumentPath] stringByAppendingString:[uploadEntity.media_object stringByDeletingLastPathComponent]];
    [self deleteFile:dir];
    [self deleteFile:[dir stringByAppendingString:@".mp4"]];
    
    NSPredicate *filter = [NSPredicate predicateWithFormat:@"file_image_original=%@", uploadEntity.file_image_original];
    [BabyUploadEntity MR_deleteAllMatchingPredicate:filter];
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
        if (completionBlock) {
            completionBlock(contextDidSave);
        }
        
    }];
}

- (void) removeFile:(NSURL *)fileURL
{
    NSString *filePath = [fileURL path];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            NSLog(@"error removing file: %@", [error localizedDescription]);
        }
    }
}

- (NSString *)getCurrentDocumentPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

- (NSString *)themeDir
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *mThemeCacheDir = [path stringByAppendingPathComponent:@"Theme"];
    BOOL isDir = FALSE;
    BOOL isDirExist = [file_manager fileExistsAtPath:mThemeCacheDir isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [file_manager createDirectoryAtPath:mThemeCacheDir withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            DLog(@"创建图片文件夹失败");
            return nil;
        }
        return mThemeCacheDir;
    }
    return mThemeCacheDir;
}

- (NSString *)updateVideoAuthorLogo:(UIImage *)image
{
    NSString *authorPath = [[self themeDir] stringByAppendingPathComponent:@"theme_author.png"];
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:authorPath]) {
        [file_manager removeItemAtPath:authorPath error:nil];
    }
    
    [UIImagePNGRepresentation(image) writeToFile:authorPath atomically:YES];
    return authorPath;
}

-(NSString*)updateWatermarkWithType:(NSString *)type image:(UIImage *)image
{
    NSString *authorPath = [[self themeDir] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",type]];
    
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:authorPath]) {
        [file_manager removeItemAtPath:authorPath error:nil];
    }
    
    [UIImagePNGRepresentation(image) writeToFile:authorPath atomically:YES];
    return authorPath;
}

- (NSString *)saveUIImageToPath:(NSString *)filePath withImage:(UIImage *)image
{
    NSFileManager *file_manager = [NSFileManager defaultManager];
    if ([file_manager fileExistsAtPath:filePath]) {
        [file_manager removeItemAtPath:filePath error:nil];
    }
    [UIImageJPEGRepresentation(image, .7) writeToFile:filePath atomically:YES];
//    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    return filePath;
}

- (void) copyFileToDocuments:(NSURL *)fileURL
{
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd_HH-mm-ss"];
    NSString *destinationPath = [documentsDirectory stringByAppendingFormat:@"/output_%@.mov", [dateFormatter stringFromDate:[NSDate date]]];
    NSError	*error;
    [[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error];
    if(error){
        NSLog(@"error copying file: %@", [error localizedDescription]);
    }
}

- (void)copyFileToCameraRoll:(NSURL *)fileURL
{
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    if(![library videoAtPathIsCompatibleWithSavedPhotosAlbum:fileURL]){
        NSLog(@"video incompatible with camera roll");
    }
    [library writeVideoAtPathToSavedPhotosAlbum:fileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        
        if(error){
            NSLog(@"Error: Domain = %@, Code = %@", [error domain], [error localizedDescription]);
        } else if(assetURL == nil){
            
            //It's possible for writing to camera roll to fail, without receiving an error message, but assetURL will be nil
            //Happens when disk is (almost) full
            NSLog(@"Error saving to camera roll: no error message, but no url returned");
            
        } else {
            //remove temp file
//            NSError *error;
//            [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
//            if(error){
//                NSLog(@"error: %@", [error localizedDescription]);
//            }
            
        }
    }];
    
}

+ (NSString *)createVideoFolderIfNotExist:(NSString *)key
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    NSString *folderPath = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSString *tempPath = [folderPath stringByAppendingPathComponent:key];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:folderPath isDirectory:&isDir];
    
    if(!(isDirExist && isDir))
    {
        BOOL bCreateDir = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        if(!bCreateDir){
            DLog(@"创建%@文件夹失败", folderPath);
            return nil;
        }
        
    }
    
    tempPath = [self createFolderIfNotExist:tempPath];
    
    return tempPath;
}

+ (NSString *)createFolderIfNotExist:(NSString *)key
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isDirExist = [fileManager fileExistsAtPath:key isDirectory:&isDir];
    if (isDirExist) {
        [fileManager removeItemAtPath:key error:nil];
    }
    BOOL bCreateDir = [fileManager createDirectoryAtPath:key withIntermediateDirectories:YES attributes:nil error:nil];
    if(!bCreateDir){
        DLog(@"创建%@文件夹失败", key);
        return nil;
    }
    
    return key;
}

+ (NSString *)getVideoMergeFilePathString:(NSString *)folderPath concatText:(NSString *)concatText
{
    
    NSString *path = [folderPath stringByAppendingPathComponent:@"concat.txt"];
    [self saveStringToFile:path concatText:concatText];
    
    return path;
}

+ (NSString *)saveStringToFile:(NSString *)filePath concatText:(NSString *)concatText
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        [fileManager removeItemAtPath:filePath error:nil];
    }
    BOOL bCreateFile = [fileManager createFileAtPath:filePath contents:nil attributes:nil];
    if (bCreateFile) {
        DLog(@"%@文件创建成功", filePath);
        
        BOOL isSuccess = [concatText writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if (isSuccess) {
            NSLog(@"write success");
        } else {
            NSLog(@"write fail");
        }
    }
    
    return filePath;
}

+ (NSURL *)getVideoSaveFilePathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return [NSURL URLWithString:fileName];
}

+ (NSString *)getVideoSaveFilePathString2
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyyMMddHHmmss";
    NSString *nowTimeStr = [formatter stringFromDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    
    NSString *fileName = [[path stringByAppendingPathComponent:nowTimeStr] stringByAppendingString:@".mp4"];
    
    return fileName;
}

+ (NSString *)getVideoSaveFolderPathString
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:VIDEO_FOLDER];
    
    return path;
}

- (MediaObject *)convertMediaObject:(MediaObject *)mediaObjec
{
    mediaObjec.mOutputObjectPath = [mediaObjec.mOutputObjectPath stringByReplacingOccurrencesOfString:[self getCurrentDocumentPath] withString:@""];
    
    mediaObjec.mOutputDirectory = [mediaObjec.mOutputDirectory stringByReplacingOccurrencesOfString:[self getCurrentDocumentPath] withString:@""];
    
    mediaObjec.mOutputVideoPath = [mediaObjec.mOutputVideoPath stringByReplacingOccurrencesOfString:[self getCurrentDocumentPath] withString:@""];
    
    return mediaObjec;
}


- (MediaObject *)convertBackMediaObject:(MediaObject *)mediaObjec
{
    mediaObjec.mOutputObjectPath = [[self getCurrentDocumentPath] stringByAppendingString:mediaObjec.mOutputObjectPath];
    
    mediaObjec.mOutputDirectory = [[self getCurrentDocumentPath] stringByAppendingString:mediaObjec.mOutputDirectory];
    
    mediaObjec.mOutputVideoPath = [[self getCurrentDocumentPath] stringByAppendingString:mediaObjec.mOutputVideoPath];
    
    return mediaObjec;
}

- (NSUInteger)degressFromVideoFileWithURL:(NSURL *)url
{
    NSUInteger degress = 0;
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if([tracks count] > 0) {
        AVAssetTrack *videoTrack = [tracks objectAtIndex:0];
        CGAffineTransform t = videoTrack.preferredTransform;
        
        if(t.a == 0 && t.b == 1.0 && t.c == -1.0 && t.d == 0){
            // Portrait
            degress = 90;
        }else if(t.a == 0 && t.b == -1.0 && t.c == 1.0 && t.d == 0){
            // PortraitUpsideDown
            degress = 270;
        }else if(t.a == 1.0 && t.b == 0 && t.c == 0 && t.d == 1.0){
            // LandscapeRight
            degress = 0;
        }else if(t.a == -1.0 && t.b == 0 && t.c == 0 && t.d == -1.0){
            // LandscapeLeft
            degress = 180;
        }
    }
    
    return degress;
}

- (NSString *)convertVideoCutTime:(long)time
{
    DLogW(@"time : %ld", time);
    NSDate* createdAt = [NSDate dateWithTimeIntervalSince1970:time];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:[NSTimeZone systemTimeZone]];
    formatter.dateFormat = @"HH:mm:ss";
    NSString *nowTimeStr = [formatter stringFromDate:createdAt];
    
    return [nowTimeStr stringByReplacingOccurrencesOfString:@"08" withString:@"00"];
}

- (uint64_t)freeDiskSpace
{
    uint64_t totalFreeSpace = 0;
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDictionary *dictionary = [fileManager attributesOfFileSystemForPath:docPath error:nil];
    if(dictionary){
        totalFreeSpace = [dictionary[NSFileSystemFreeSize] unsignedLongLongValue];
    }
    return totalFreeSpace;
}

@end
