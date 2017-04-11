//
//  BabyPinUpload.h
//  Babypai
//
//  Created by ning on 16/5/11.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BabyUploadEntity.h"

typedef void (^UploadCompletionBlock)(NSString* data, NSString* errorString);

typedef void (^UploadProgressBlock)(float progress);

@interface BabyPinUpload : NSObject

+ (instancetype)upload;

- (void)startUploadWithCompletion:(UploadCompletionBlock)completionBlock progress:(UploadProgressBlock)progressBlock;

- (float)uploadProgress;

- (BOOL)isUploading:(BabyUploadEntity *)mUploadEntity;

@end
