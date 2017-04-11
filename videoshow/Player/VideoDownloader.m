//
//  VideoDownloader.m
//  Babypai
//
//  Created by ning on 15/8/2.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import "VideoDownloader.h"
#import "AFNetworking.h"

@implementation VideoDownloader

+ (VideoDownloader *)videoDownloader
{
    
    static dispatch_once_t onceToken;
    static VideoDownloader *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[VideoDownloader alloc]init];
    });
    
    return instance;
    
}

- (void)downloadVideo:(NSString *) videoPath completion:(DownloadCompletionBlock)completionBlock progress:(DownloadProgressBlock)progressBlock
{
    
    if (completionBlock)
    {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        NSString *cacheDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *cacheVideoDir = [cacheDirectory stringByAppendingPathComponent:@"videos"];
        NSString *downloadPath = [cacheVideoDir stringByAppendingPathComponent:[videoPath lastPathComponent]];
        NSLog(@"downloadPath is : %@", downloadPath);
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:downloadPath]){
            NSLog(@"downloadPath is exists.....");
//            dispatch_async(dispatch_get_main_queue(), ^{
                [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                completionBlock(downloadPath, nil);
//            });
            return;
        }
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:videoPath]];

        //不使用缓存，避免断点续传出现问题
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:request];

        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
        
        NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
            // This is not called back on the main queue.
            // You are responsible for dispatching to the main queue for UI updates
            dispatch_async(dispatch_get_main_queue(), ^{
                //Update the progress view
                progressBlock(uploadProgress.fractionCompleted);
            });} destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            return [NSURL fileURLWithPath:downloadPath];
        } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
            NSLog(@"File downloaded to: %@", filePath);
            [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
             completionBlock([filePath absoluteString], nil);
        }];
        [downloadTask resume];
        
        
    }
    
}


//获取已下载的文件大小
- (unsigned long long)fileSizeForPath:(NSString *)path {
    signed long long fileSize = 0;
    NSFileManager *fileManager = [NSFileManager new]; // default is not thread safe
    if ([fileManager fileExistsAtPath:path]) {
        NSError *error = nil;
        NSDictionary *fileDict = [fileManager attributesOfItemAtPath:path error:&error];
        if (!error && fileDict) {
            fileSize = [fileDict fileSize];
        }
    }
    return fileSize;
}

@end
