//
//  BabyFileDownloadManager.h
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyFileDownload.h"

typedef NS_ENUM(NSInteger, FileDownloadState){
    FileDownloadStateWaiting = 0,
    FileDownloadStateDownloading = 1,
    FileDownloadStateSuspending = 2,
    FileDownloadStateFail = 3,
    FileDownloadStateFinish = 4,
};

@protocol BabyFileDownloadManagerDelegate <NSObject>

/*
 下载开始
 */
- (void)fileDownloadManagerStartDownload:(BabyFileDownload *)download;
/*
 更新下载进度
 */
- (void)fileDownloadManagerProgress:(BabyFileDownload *)download progress:(float)progress;

/*
 下载完成，包括成功和失败
 */
- (void)fileDownloadManagerFinishDownload:(BabyFileDownload *)download success:(BOOL)downloadSuccess filePath:(NSString *)filePath error:(NSError *)error;

@end

@interface BabyFileDownloadManager : NSObject

+ (instancetype)sharedFileDownloadManager;

@property (assign, nonatomic) NSInteger maxConDownloadCount;             //当前队列最大同时下载数，默认值是1
@property (assign, nonatomic, readonly) NSInteger currentDownloadCount;  //当前队列中下载数，包括正在下载的和等待的
@property (assign, nonatomic) id<BabyFileDownloadManagerDelegate>delegate;

//添加到下载队列
- (void)addDownloadWithFileId:(long)fileId fileUrl:(NSString *)url directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName;

//点击等待项（－》立刻下载／do nothing）
- (void)startDownloadWithFileId:(long)fileId;

//点击下载项 －》暂停
- (void)suspendDownloadWithFileId:(long)fileId;

//点击暂停项（－》立刻下载／添加到下载队列）
- (void)recoverDownloadWithFileId:(long)fileId;

//取消下载，且删除文件，只适用于未下载完成状态，下载完成的直接根据路径删除即可
- (void)cancelDownloadWithFileId:(long)fileId;

//暂停全部
- (void)suspendAllFilesDownload;

//恢复全部
- (void)recoverAllFilesDownload;

//取消全部
- (void)cancelAllFilesDownload;

//获得状态
- (FileDownloadState)getFileDownloadStateWithFileId:(long)fileId;

@end
