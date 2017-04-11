//
//  BabyFileDownload.m
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyFileDownload.h"
#import "AFNetworking.h"

typedef NS_ENUM(NSInteger, FileDownloadOperationState){
    FileDownloadOperationStateWaiting = 0,     //加入到队列中，处于等待状态(默认)
    FileDownloadOperationStateExecuting = 1,   //正在执行状态
    FileDownloadOperationStateFinished = 2,    //已经完成状态
};

#define ErrorDomain  @"BabyFileDownloadErrorDomain"
#define expectedDataLength 100 * 1000 * 1000 // 100Mb

@interface BabyFileDownload()

@property (strong, nonatomic) NSURL *downloadURL;
@property (strong, nonatomic) NSString *tempFileName;
@property (assign, nonatomic) FileDownloadOperationState operationState;

@end

@implementation BabyFileDownload


- (id)initWithURL:(NSString *)fileUrl directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName delegate:(id<BabyFileDownloadDelegate>)delegate
{
    DLogV(@"initWithURL : fileUrl : %@, directoryPath : %@, fileName : %@", fileUrl, directoryPath, fileName);
    
    if(self = [super init]){
        self.fileUrl = fileUrl;
        self.fileName = fileName;
        self.delegate = delegate;
        self.directoryPath = directoryPath;
        self.operationState = FileDownloadOperationStateWaiting;
        self.tempFileName = [NSString stringWithFormat:@"tmp_%@",fileName];
        self.downloadURL = [NSURL URLWithString:[fileUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return self;
}

#pragma mark --- Public Method ---

- (void)cancelDownload
{
    [self deleteFile:[self filePath]];
    [self finishOperation];
}

#pragma mark --- Override Method ---

- (void)main
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:[self finishFilePath] error:nil];
    if([fileManager fileExistsAtPath:[self finishFilePath]]){
//        if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadStart:hasDownloadComplete:)]){
//            [_delegate fileDownloadStart:self hasDownloadComplete:YES];
//        }
        DLogV(@"file has exist");
        
        if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:success:filePath:error:)]){
            [_delegate fileDownloadFinish:self success:YES filePath:[self finishFilePath] error:nil];
        }
        
        [self finishWithUnStart];
    }
    else{
        NSURLRequest *fileRequest = [[NSURLRequest alloc] initWithURL:_downloadURL];
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:fileRequest];
        if(![NSURLConnection canHandleRequest:fileRequest]){
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:[NSString stringWithFormat:@"Invalid URL %@",_downloadURL.path]};
            NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:1 userInfo:userInfo];
            if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:success:filePath:error:)]){
                [_delegate fileDownloadFinish:self success:NO filePath:nil error:error];
            }
            [self finishWithUnStart];
        }
        else{
            if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadStart:hasDownloadComplete:)]){
                [_delegate fileDownloadStart:self hasDownloadComplete:NO];
            }
            
            if(![fileManager fileExistsAtPath:self.directoryPath]){
                [fileManager createDirectoryAtPath:self.directoryPath withIntermediateDirectories:YES attributes:nil error:nil];
            }
            
            //_expectedDataLength=-1代表暂时不知道文件大小，只能下下来才能确定
            if([self freeDiskSpace] < expectedDataLength){
                NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"Not enough free disk space"};
                NSError *error = [[NSError alloc] initWithDomain:ErrorDomain code:3 userInfo:userInfo];
                if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:success:filePath:error:)]){
                    [_delegate fileDownloadFinish:self success:NO filePath:nil error:error];
                }
                [self finishWithUnStart];
            }
            
            
            NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
            AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
            
            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:fileRequest progress:^(NSProgress * _Nonnull uploadProgress) {
                    // This is not called back on the main queue.
                    // You are responsible for dispatching to the main queue for UI updates
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadProgress:progress:)]){
                        [_delegate fileDownloadProgress:self progress:uploadProgress.fractionCompleted];
                    }
                });
                } destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                    return [NSURL fileURLWithPath:[self filePath]];
                } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                    if(!error){
                        DLog(@"File downloaded to: %@", filePath);
                        [self changeToRealFileName];
                        [self finishOperation];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:success:filePath:error:)]){
                                [_delegate fileDownloadFinish:self success:YES filePath:[self finishFilePath] error:nil];
                            }
                        });
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadFinish:success:filePath:error:)]){
                                [_delegate fileDownloadFinish:self success:NO filePath:nil error:error];
                            }
                        });
                        [self cancelDownload];
                    }
                    
                }];
            [downloadTask resume];
        }
    }
}

- (void)start
{
    if(self.isCancelled){
        [self finishWithUnStart];
    }
    else{
        [self willChangeValueForKey:@"isExecuting"];
        [self performSelector:@selector(main)];
        self.operationState = FileDownloadOperationStateExecuting;
        [self didChangeValueForKey:@"isExecuting"];
    }
}

- (BOOL)isExecuting
{
    return self.operationState == FileDownloadOperationStateExecuting;
}

- (BOOL)isFinished
{
    return self.operationState == FileDownloadOperationStateFinished;
}

- (BOOL)isAsynchronous
{
    return YES;
}

#pragma mark --- Private Method ---

//获取磁盘剩余空间
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

//未开始就取消
- (void)finishWithUnStart
{
    [self willChangeValueForKey:@"isFinished"];
    self.operationState = FileDownloadOperationStateFinished;
    [self didChangeValueForKey:@"isFinished"];
}

//完成或者取消
- (void)finishOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.operationState = FileDownloadOperationStateFinished;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

//完成了改成真正想要存储的名字
- (void)changeToRealFileName
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:[self filePath] isDirectory:NULL]){
        DLogW(@"changeToRealFileName---");
        [fileManager moveItemAtPath:[self filePath] toPath:[self finishFilePath] error:NULL];
    }
}

// 删除文件
- (void)deleteFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:filePath]) {
        NSError *error;
//        [fileManager removeItemAtPath:filePath error:&error];
        if(error){
            DLogE(@"error removing file: %@", [error localizedDescription]);
        }
    }
}

//文件夹和临时文件拼接后的路径
- (NSString *)filePath
{
    return [self.directoryPath stringByAppendingPathComponent:self.tempFileName];
}

//文件夹和文件拼接后的路径
- (NSString *)finishFilePath
{
    return [self.directoryPath stringByAppendingPathComponent:self.fileName];
}

@end
