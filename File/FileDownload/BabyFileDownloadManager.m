//
//  BabyFileDownloadManager.m
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyFileDownloadManager.h"

/*
 一个operation在Queue中正在等待，绝对不允许对他的状态做任何改变！！绝对不允许对他的状态做任何改变！！绝对不允许对他的状态做任何改变！！
 这里指的是isFinished关联的状态 KVO绝对不能在未执行start方法之前就改动
 If you call “start” on an instance of NSOperation, without adding it to a queue, the operation will run in the main loop.
 尽管 operation 是支持取消操作的，但却并不是立即取消的，而是在你调用了 operation 的 cancel 方法之后的下一个 isCancelled 的检查点取消的。
 通俗地说，就是有延迟！！有延迟！！有延迟！！
 */

//默认最大同时下载数，最好不超过3
#define  DefaultMaxDownloadCount    1

/*
 点击等待状态时响应方法，通常来说有三种：1种是立即去下载；另1种是无响应；第三种是暂停（因为已经存在于下载队列，只是还没排上队）
 点击暂停状态时响应方法，通常来说有两种：1种是立即去下载；另1种是仅添加到下载队列。
 可在1和0之间切换如下值体验不同方式
 */

#define  RESPONSE_TO_WAITING_WAY_ONE      1
#define  RESPONSE_TO_WAITING_WAY_TWO      0
#define  RESPONSE_TO_SUSPEND_WAY          1

@interface BabyFileDownloadManager () <BabyFileDownloadDelegate>

@property (strong, nonatomic) NSOperationQueue *downloadQueue;            //下载队列
@property (strong, nonatomic) NSMutableArray *suspendDownloadArr;         //取消的下载

@end

@implementation BabyFileDownloadManager


+ (instancetype)sharedFileDownloadManager
{
    static dispatch_once_t onceToken;
    static BabyFileDownloadManager *fileDownloadManager = nil;
    dispatch_once(&onceToken, ^{
        fileDownloadManager = [[BabyFileDownloadManager alloc] init];
    });
    return fileDownloadManager;
}

- (instancetype)init
{
    if(self = [super init]){
        _suspendDownloadArr = [NSMutableArray array];
        _downloadQueue = [[NSOperationQueue alloc] init];
        _downloadQueue.maxConcurrentOperationCount = DefaultMaxDownloadCount;
    }
    return self;
}

#pragma mark --- Publick Download ---

- (void)addDownloadWithFileId:(long)fileId fileUrl:(NSString *)url directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName
{
    
    DLogV(@"addDownloadWithFileId : fileId : %ld, fileUrl : %@, directoryPath : %@, fileName : %@", fileId, url, directoryPath, fileName);
    
    BabyFileDownload *fileDownload = [[BabyFileDownload alloc] initWithURL:url directoryPath:directoryPath fileName:fileName delegate:self];
    fileDownload.fileId = fileId;
    [_downloadQueue addOperation:fileDownload];
}

- (void)startDownloadWithFileId:(long)fileId
{
    if(self.currentDownloadCount==0){
        return;
    }
    //do nothing
    if(RESPONSE_TO_WAITING_WAY_ONE){
        return;
    }
    //去暂停
    if(RESPONSE_TO_WAITING_WAY_TWO){
        for(NSInteger i=self.maxConDownloadCount;i<self.currentDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            if(fileDownload.fileId == fileId){
                [fileDownload cancel];
                [_suspendDownloadArr addObject:fileDownload];
                break;
            }
        }
        return;
    }
    //立即去下载
    NSMutableArray *tmpCancelArray = [NSMutableArray array];
    BabyFileDownload *chooseDownload = nil;
    for(NSInteger i=self.maxConDownloadCount;i<self.currentDownloadCount;i++){
        BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
        [fileDownload cancel];
        if(fileDownload.fileId == fileId){
            chooseDownload = fileDownload;
        }
        else{
            [tmpCancelArray addObject:fileDownload];
        }
    }
    BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:self.maxConDownloadCount-1];
    [fileDownload cancelDownload];
    [self addToDownloadWithFileDownload:chooseDownload];
    [self addToDownloadWithFileDownload:fileDownload];
    for(BabyFileDownload *fileDownload in tmpCancelArray){
        [self addToDownloadWithFileDownload:fileDownload];
    }
}

- (void)suspendDownloadWithFileId:(long)fileId
{
    for(BabyFileDownload *fileDownload in _downloadQueue.operations){
        if(fileDownload.fileId == fileId){
            [fileDownload cancelDownload];
            [_suspendDownloadArr addObject:fileDownload];
            break;
        }
    }
}

- (void)recoverDownloadWithFileId:(long)fileId
{
    //添加到下载队列
    if(RESPONSE_TO_SUSPEND_WAY){
        [self addToDownloadInSuspendArrayWithFileId:fileId];
        return;
    }
    //立即去下载
    if([self canAddOperationWithoutCancel]){
        [self addToDownloadInSuspendArrayWithFileId:fileId];
    }
    else if([self hasWaitingOperations]){
        NSMutableArray *tmpCancelArray = [NSMutableArray array];
        for(NSInteger i=self.maxConDownloadCount;i<self.currentDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            [fileDownload cancel];
            [tmpCancelArray addObject:fileDownload];
        }
        BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:self.maxConDownloadCount-1];
        [fileDownload cancelDownload];
        [self addToDownloadInSuspendArrayWithFileId:fileId];
        [self addToDownloadWithFileDownload:fileDownload];
        for(BabyFileDownload *fileDownload in tmpCancelArray){
            [self addToDownloadWithFileDownload:fileDownload];
        }
    }
    else{
        BabyFileDownload *fileDownload = [_downloadQueue.operations lastObject];
        [fileDownload cancelDownload];
        [self addToDownloadInSuspendArrayWithFileId:fileId];
        [self addToDownloadWithFileDownload:fileDownload];
    }
}

- (void)cancelDownloadWithFileId:(long)fileId
{
    //先从下载队列中寻找
    NSString *filePath = @"";
    for(BabyFileDownload *fileDownload in _downloadQueue.operations){
        if(fileDownload.fileId == fileId){
            filePath = [self tmpFilePathWithDirectoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
            [fileDownload cancelDownload];
            [self removeTmpFileWithPath:filePath];
            return;
        }
    }
    //再从暂停列表中寻找
    for(BabyFileDownload *fileDownload in _suspendDownloadArr){
        if(fileDownload.fileId == fileId){
            filePath = [self tmpFilePathWithDirectoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
            [_suspendDownloadArr removeObject:fileDownload];
            [self removeTmpFileWithPath:filePath];
            return;
        }
    }
}

- (void)suspendAllFilesDownload
{
    //需要区分是正在执行的还是等待的，先把排队中的cancel掉，再把正在执行的finish掉
    if([self hasWaitingOperations]){
        NSMutableArray *tmpCancelArray = [NSMutableArray array];
        for(NSInteger i=self.maxConDownloadCount;i<self.currentDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            [fileDownload cancel];
            [_suspendDownloadArr addObject:fileDownload];
        }
        NSMutableArray *downloadingCancelArray = [NSMutableArray array];
        for(NSInteger i=0;i<self.maxConDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            [downloadingCancelArray addObject:fileDownload];
        }
        for(BabyFileDownload *fileDownload in downloadingCancelArray){
            [fileDownload cancelDownload];
        }
        [tmpCancelArray addObjectsFromArray:downloadingCancelArray];
        [tmpCancelArray addObjectsFromArray:_suspendDownloadArr];
        self.suspendDownloadArr = tmpCancelArray;
    }
    else{
        for(BabyFileDownload *fileDownload in _downloadQueue.operations){
            [fileDownload cancelDownload];
            [_suspendDownloadArr addObject:fileDownload];
        }
    }
}

- (void)recoverAllFilesDownload
{
    for(BabyFileDownload *fileDownload in _suspendDownloadArr){
        [self addToDownloadWithFileDownload:fileDownload];
    }
    [_suspendDownloadArr removeAllObjects];
}

- (void)cancelAllFilesDownload
{
    //先把排队的取消掉，再把正在下载的取消掉
    if([self hasWaitingOperations]){
        for(NSInteger i=self.maxConDownloadCount;i<self.currentDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            NSString *filePath = [self tmpFilePathWithDirectoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
            [fileDownload cancel];
            [self removeTmpFileWithPath:filePath];
        }
        NSMutableArray *downloadingCancelArray = [NSMutableArray array];
        for(NSInteger i=0;i<self.maxConDownloadCount;i++){
            BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
            [downloadingCancelArray addObject:fileDownload];
        }
        for(BabyFileDownload *fileDownload in downloadingCancelArray){
            NSString *filePath = [self tmpFilePathWithDirectoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
            [fileDownload cancelDownload];
            [self removeTmpFileWithPath:filePath];
        }
    }
    else{
        for(BabyFileDownload *fileDownload in _downloadQueue.operations){
            [fileDownload cancelDownload];
        }
    }
    for(BabyFileDownload *fileDownload in _suspendDownloadArr){
        NSString *filePath = [self tmpFilePathWithDirectoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
        [self removeTmpFileWithPath:filePath];
    }
    [_suspendDownloadArr removeAllObjects];
}

- (FileDownloadState)getFileDownloadStateWithFileId:(long)fileId
{
    //下载列表中包括正在下载和等待下载中，已经完成的不论成功或失败均不在此列
    for(BabyFileDownload *fileDownload in _suspendDownloadArr){
        if(fileDownload.fileId == fileId){
            return FileDownloadStateSuspending;
        }
    }
    
    NSInteger findCount = 0;
    NSInteger findIndex = 0;
    for(int i=0;i<self.currentDownloadCount;i++){
        if(i>=_downloadQueue.operations.count){
            return FileDownloadStateWaiting;
        }
        BabyFileDownload *fileDownload = [_downloadQueue.operations objectAtIndex:i];
        if(fileDownload.fileId == fileId){
            findCount++;
            findIndex=i;
        }
    }
    
    if(findCount==1 && findIndex<self.maxConDownloadCount){
        return FileDownloadStateDownloading;
    }
    
    return FileDownloadStateWaiting;
}

#pragma mark --- Private Method ---

- (BOOL)hasWaitingOperations
{
    return self.currentDownloadCount>self.maxConDownloadCount;
}

- (BOOL)canAddOperationWithoutCancel
{
    return self.maxConDownloadCount>self.currentDownloadCount;
}

- (NSString *)tmpFilePathWithDirectoryPath:(NSString *)directoryPath fileName:(NSString *)fileName
{
    return [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_tmp",fileName]];
}

- (void)removeTmpFileWithPath:(NSString *)tmpFilePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:tmpFilePath]){
        [fileManager removeItemAtPath:tmpFilePath error:nil];
    }
}

- (void)addToDownloadInSuspendArrayWithFileId:(long)fileId
{
    for(int i=0; i<_suspendDownloadArr.count; i++) {
        BabyFileDownload *download = _suspendDownloadArr[i];
        if(download.fileId == fileId){
            [self addDownloadWithFileId:fileId fileUrl:download.fileUrl directoryPath:download.directoryPath fileName:download.fileName];
            [_suspendDownloadArr removeObject:download];
            download = nil;
            return;
        }
    }
}

- (void)addToDownloadWithFileDownload:(BabyFileDownload *)fileDownload
{
    [self addDownloadWithFileId:fileDownload.fileId fileUrl:fileDownload.fileUrl directoryPath:fileDownload.directoryPath fileName:fileDownload.fileName];
}

#pragma mark --- Set & Get ---

- (void)setMaxConDownloadCount:(NSInteger)maxConDownloadCount
{
    _downloadQueue.maxConcurrentOperationCount = maxConDownloadCount;
}

- (NSInteger)maxConDownloadCount
{
    return _downloadQueue.maxConcurrentOperationCount;
}

- (NSInteger)currentDownloadCount
{
    return [_downloadQueue.operations count];
}

#pragma mark --- BabyFileDownloadDelegate ---

- (void)fileDownloadStart:(BabyFileDownload *)download hasDownloadComplete:(BOOL)downloadComplete
{
    if(downloadComplete){
        // 这个调用暂时用不到
        [self fileDownloadFinish:download success:YES filePath:nil error:nil];
    }
    else{
        dispatch_async(dispatch_get_main_queue(), ^{
            if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerStartDownload:)]){
                [_delegate fileDownloadManagerStartDownload:download];
            }
        });
    }
}

- (void)fileDownloadProgress:(BabyFileDownload *)download progress:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerProgress:progress:)]){
            [_delegate fileDownloadManagerProgress:download progress:progress];
        }
    });
}

- (void)fileDownloadFinish:(BabyFileDownload *)download success:(BOOL)downloadSuccess filePath:(NSString *)filePath error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(_delegate && [_delegate respondsToSelector:@selector(fileDownloadManagerFinishDownload:success:filePath:error:)]){
            [_delegate fileDownloadManagerFinishDownload:download success:downloadSuccess filePath:filePath error:error];
        }
    });
}

@end
