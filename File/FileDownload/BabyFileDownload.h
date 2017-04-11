//
//  BabyFileDownload.h
//  Babypai
//
//  Created by ning on 16/5/19.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroDefinition.h"

@class BabyFileDownload;

@protocol BabyFileDownloadDelegate <NSObject>

- (void)fileDownloadStart:(BabyFileDownload *)download hasDownloadComplete:(BOOL)downloadComplete;
- (void)fileDownloadProgress:(BabyFileDownload *)download progress:(float)progress;
- (void)fileDownloadFinish:(BabyFileDownload *)download success:(BOOL)downloadSuccess filePath:(NSString *)filePath error:(NSError *)error;

@end

@interface BabyFileDownload : NSOperation

@property (assign, nonatomic) long fileId;           //文件的唯一标识
@property (copy, nonatomic) NSString *fileUrl;          //文件的网址
@property (copy, nonatomic) NSString *fileName;         //文件的名字
@property (copy, nonatomic) NSString *directoryPath;    //文件所在文件夹路径
@property (assign, nonatomic) id<BabyFileDownloadDelegate>delegate;

- (id)initWithURL:(NSString *)fileUrl directoryPath:(NSString *)directoryPath fileName:(NSString *)fileName delegate:(id<BabyFileDownloadDelegate>)delegate;

- (void)cancelDownload;

@end
