//
//  BabyPinUpload.m
//  Babypai
//
//  Created by ning on 16/5/11.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "BabyPinUpload.h"
#import "BabyFileManager.h"
//#import "UpYun.h"
#import "PinInfo.h"
#import "StringUtils.h"
#import "MJExtension.h"


@interface BabyPinUpload()

@property (nonatomic, assign) float uploadProgress;
@property(nonatomic, strong) BabyUploadEntity *uploadEntity;

/**
 *  要上传文件的地址
 */
@property (nonatomic ,strong) NSString *filePath;

/**
 *  上传到又拍云的文件名称
 */
@property (nonatomic ,strong) NSString *fileName;

/**
 *  上传到又拍云的文件路径
 */
@property (nonatomic ,strong) NSString *uploadPath;

/**
 *  上传到第几步了，0：没有，1：正在上传图片，2：正在上传（音/视频）文件
 */
@property (nonatomic, assign) int afterUpload;

@property (nonatomic, strong) UploadCompletionBlock completionBlock;
@property (nonatomic, strong) UploadProgressBlock progressBlock;

@end

@implementation BabyPinUpload

+ (instancetype)upload
{
    static BabyPinUpload *upload;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        upload = [[self alloc] init];
    });
    return upload;
}

- (void)startUploadWithCompletion:(UploadCompletionBlock)completionBlock progress:(UploadProgressBlock)progressBlock
{
    _completionBlock = completionBlock;
    _progressBlock = progressBlock;
    
    [self getUploadData];
    
}

- (void)getUploadData
{
    
//    NSPredicate *filter = [NSPredicate predicateWithFormat:@"is_draft=%@ AND is_publish=%@", @"0", @"0"];
//    _uploadEntity = [BabyUploadEntity MR_findFirstWithPredicate:filter sortedBy:@"file_time" ascending:NO];
//    DLog(@"_uploadEntity.file_image_original : %@", _uploadEntity.file_image_original);
//    if (_uploadEntity == nil || [StringUtils isEmpty:_uploadEntity.file_image_original]) {
//        DLog(@"no upload data...");
//        _completionBlock(@"no upload data", @"no upload data");
//        return;
//    }
//    
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
//    _uploadPath = [NSString stringWithFormat:@"%@/", [dateFormatter stringFromDate:[NSDate date]]];
//    
//    
//    _filePath = _uploadEntity.file_image_path;
//    
//    if ([_uploadEntity.file_format isEqualToString:FILE_FORMAT_IMAGE]) {
//        _afterUpload = 1;
//    } else {
//        if ([_uploadEntity.file_isupload intValue] == 0) {
//            _afterUpload = 1;
//        } else {
//            _afterUpload = 2;
//            _filePath = _uploadEntity.file_video_path;
//        }
//    }
//    
//    if ([_uploadEntity.file_format isEqualToString:FILE_FORMAT_IMAGE]) {
////        [UPYUNConfig sharedInstance].DEFAULT_BUCKET = IMAGE_BUCKET_NAME;
////        [UPYUNConfig sharedInstance].DEFAULT_PASSCODE = FILE_IMAGE_KEY;
//        _fileName = [NSString stringWithFormat:@"/%@%@", _uploadPath, [_filePath lastPathComponent]];
//    } else {
//        
//        if ([_uploadEntity.file_isupload intValue] == 0) {
////            [UPYUNConfig sharedInstance].DEFAULT_BUCKET = IMAGE_BUCKET_NAME;
////            [UPYUNConfig sharedInstance].DEFAULT_PASSCODE = FILE_IMAGE_KEY;
//            _fileName = [NSString stringWithFormat:@"/%@%@", _uploadPath, [_filePath lastPathComponent]];
//        } else {
////            [UPYUNConfig sharedInstance].DEFAULT_BUCKET = FILE_BUCKET_NAME;
////            [UPYUNConfig sharedInstance].DEFAULT_PASSCODE = FILE_KEY;
//            _fileName = [NSString stringWithFormat:@"/video/%@%@", _uploadPath, [_filePath lastPathComponent]];
//        }
//        
//    }
//    
////    __block UpYun *uy = [[UpYun alloc] init];
//    
////    uy.successBlocker = ^(NSURLResponse *response, id responseData) {
////        
////        _uploadEntity.file_isupload = [NSNumber numberWithInt:_afterUpload];
////        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
////            if (contextDidSave) {
////                DLog(@"保存完成了");
////            } else {
////                DLog(@"保存失败了");
////            }
////            
////            if ([_uploadEntity.file_format isEqualToString:FILE_FORMAT_IMAGE] && _afterUpload == 1) {
////                [self pinPost];
////            } else if ( _afterUpload == 2 ) {
////                [self pinPost];
////            } else {
////                [self getUploadData];
////            }
////        }];
////        
////        
////        
////        
////    };
////    uy.failBlocker = ^(NSError * error) {
////        NSString *message = [error.userInfo objectForKey:@"message"];
////        DLog(@"message : %@", message);
////        _completionBlock(_fileName, message);
////    };
////    uy.progressBlocker = ^(CGFloat percent, int64_t requestDidSendBytes) {
////        if (_afterUpload > 1) {
////            _uploadProgress = percent;
////            _progressBlock(_uploadProgress);
////        }
////        
////    };
//    
//    NSString *uploadFilePath = [[[BabyFileManager manager] getCurrentDocumentPath] stringByAppendingPathComponent:_filePath];
//    
//    
//    
//    
//    /**
//     *	@brief	根据 UIImage 上传
//     */
//    //    UIImage * image = [UIImage imageNamed:@"test2.png"];
//    //    [uy uploadFile:image saveKey:[self getSaveKeyWith:@"jpg"]];
//    
//    //    [uy uploadFile:image saveKey:@"2016.jpg"];
//    //    [uy uploadImage:image savekey:[self getSaveKeyWith:@"png"]];
//    /**
//     *	@brief	根据 文件路径 上传
//     */
//    DLog(@"_fileName : %@", _fileName);
//    [uy uploadFile:uploadFilePath saveKey:_fileName];
}

- (float)uploadProgress
{
    
    return 0.0f;
}

- (BOOL)isUploading:(BabyUploadEntity *)mUploadEntity
{
    
    return false;
}

- (void)pinPost
{
    DLog(@"pinPost");
    NSString *file_mp3_name = @"";
    long file_mp3_time = 0;
    long file_video_time = 0;
    NSString *file_video_name = @"";
    if (_uploadEntity.file_video_path.length > 1) {
        file_video_time = [_uploadEntity.file_video_time longValue];
        file_video_name = [_uploadEntity.file_video_path lastPathComponent];
    }
    
    int province_id = [_uploadEntity.province_id intValue];
    int city_id = [_uploadEntity.city_id intValue];
    int area_id = [_uploadEntity.area_id intValue];
    NSString *province = _uploadEntity.province;
    NSString *city = _uploadEntity.city;
    NSString *area = _uploadEntity.area;
    NSString *addr = _uploadEntity.addr;
    double longitude = [_uploadEntity.longitude doubleValue];
    double latitude = [_uploadEntity.latitude doubleValue];
    NSString *keywords = _uploadEntity.keywords;

    NSString *fields = [NSString stringWithFormat:@"{\"uid\":\"%ld\",\"board_id\":\"%ld\",\"file_path\":\"%@\",\"file_image_name\":\"%@\",\"file_mp3_name\":\"%@\",\"file_mp3_time\":\"%ld\",\"file_video_name\":\"%@\",\"file_video_time\":\"%ld\",\"raw_text\":\"%@\",\"tag_id\":\"%@\",\"at_uid\":\"%@\",\"province_id\":\"%d\",\"city_id\":\"%d\",\"area_id\":\"%d\",\"province\":\"%@\",\"city\":\"%@\",\"area\":\"%@\",\"addr\":\"%@\",\"longitude\":\"%f\",\"latitude\":\"%f\",\"keywords\":\"%@\",\"is_private\":\"%d\"}", [Utils userId], [_uploadEntity.board_id longValue], _uploadPath, [_uploadPath stringByAppendingString:[_uploadEntity.file_image_path lastPathComponent]], [_uploadPath stringByAppendingString:file_mp3_name], file_mp3_time, [_uploadPath stringByAppendingString:file_video_name], file_video_time, _uploadEntity.raw_text, _uploadEntity.tag_id, _uploadEntity.at_uid, province_id, city_id, area_id, province, city, area, addr, longitude, latitude, keywords, [_uploadEntity.is_private intValue]];
    
    
    DataCompletionBlock dataCompletionBlock = ^(NSDictionary *data, NSString *errorString){
        
        //shua xin stop
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        if (data != nil) {
            [self processPinData:data];
        }
    };
    
    
    BabyDataSource *souce = [BabyDataSource dataSource];
    
    [souce getData:PIN_ADD parameters:fields completion:dataCompletionBlock];
    
}

- (void)processPinData:(NSDictionary *)data
{
    PinInfo *pinInfo = [PinInfo mj_objectWithKeyValues:data];
    
    if (pinInfo.msg == 0) {
        _uploadEntity.is_publish = [NSNumber numberWithInt:1];
        [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError * _Nullable error) {
            [[BabyFileManager manager]deleteUploadEntity:_uploadEntity withCompletion:^(BOOL contextDidSave) {
                [self getUploadData];
            }];
        }];
        
        _completionBlock(_fileName, nil);
        
        if (pinInfo.info != nil) {
            
//            // 要播放的音频文件地址
//            NSString *urlPath = [[NSBundle mainBundle] pathForResource:@"child_smile" ofType:@"mp3"];
//            NSURL *url = [NSURL fileURLWithPath:urlPath];
//            // 声明需要播放的音频文件ID[unsigned long]
//            SystemSoundID ID;
//            // 创建系统声音，同时返回一个ID
//            AudioServicesCreateSystemSoundID((__bridge CFURLRef)(url), &ID);
//            // 根据ID播放自定义系统声音
//            AudioServicesPlaySystemSound(ID);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PIN_UPLOAD object:self userInfo:@{@"pin":pinInfo.info}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_PIN_UPLOAD object:self userInfo:@{}];
        }
        
    }
}

@end
