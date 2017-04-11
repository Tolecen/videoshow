//
//  Utils.h
//  Babypai
//
//  Created by ning on 15/4/9.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//






#import <Foundation/Foundation.h>
#import "UserInfomation.h"
#import "BabyFile.h"
#import <Photos/PHAsset.h>
#import <Photos/PHImageManager.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "MacroDefinition.h"



typedef void(^ResultPath)(NSString *filePath, NSString *fileName);

@interface Utils : NSObject

//@property (nonatomic,strong) UserInfomation *userInfomation;

+ (instancetype)utils;

+ (CGFloat)contentCellHeightWithText:(NSString *)text contentWidth:(int)width fontSize:(UIFont *)font;

+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration;

+ (void)heartbeatView:(UIView *)view duration:(CGFloat)fDuration maxSize:(CGFloat)fMaxSize durationPerBeat:(CGFloat)fDurationPerBeat;

+ (void)shakeView:(UIView *)view duration:(CGFloat)fDuration;

+ (NSString *)friendTime:(long)message;

+ (NSString *)dataTOjsonString:(id)object;

+ (void)updataUserInfo:(NSString *)userInfo;

+ (void)updataUserInfoDic:(UserInfomation *)userInfo;

+ (long)userId;

+ (UserInfomation *)userInfomation;

+ (NSString *)getImagePath:(BabyFile *)file tagWith:(NSString *)tag;

+ (NSURL *)getImagePathURL:(BabyFile *)file tagWith:(NSString *)tag;

+ (NSString *)getVideoPath:(BabyFile *)file;

+ (void)setUserDefault:(NSString *)data nameWith:(NSString *)name;

+ (NSString *)getUserDefaultStringWithName:(NSString *)name;

+ (NSDictionary *)getUserDefaultWithName:(NSString *)name;

+ (NSString *)urlJiexi:(NSString *)key webAddress:(NSString *)webAddress;

+ (NSString *)urlScheme:(NSString *)parten resourceSpecifier:(NSString *)resourceSpecifier;

- (BOOL)isFileExists:(NSString *)filePath;

- (void)copyFileFromAsset:(id)asset Complete:(ResultPath)result;

- (BOOL)canAutoPlay:(BOOL)isNetworkWAN;



@end
