//
//  lz_VideoTemplateModel.h
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseModel.h"

@interface lz_VideoTemplateModel : BaseModel


//请求视频模板分类
+ (void) requestStyleWithSuccessHandle:(SuccessHandle)SuccessHandle
                         FailureHandle:(FailureHandle)FailureHandle;

//请求视频列表
+ (void) requestWithStyleId:(NSNumber *)styleid
                   isCharge:(NSNumber *)ischarge
                      shortTime:(NSString *)shortTime
                  pageIndex:(NSNumber *)page
                     length:(NSNumber *)length
          SuccessHandle:(SuccessHandle)SuccessHandle
          FailureHandle:(FailureHandle)FailureHandle;

@property (nonatomic, copy) NSString *charge_money;//
@property (nonatomic, copy) NSString *template_id;//
@property (nonatomic, copy) NSString *is_charge;//
@property (nonatomic, copy) NSString *has_collected;//是否收藏
@property (nonatomic, copy) NSString *template_click;//
@property (nonatomic, copy) NSString *template_name;//
@property (nonatomic, copy) NSString *template_picture;//
@property (nonatomic, strong) UIImage *template_image;//存储下载下来的pic
@property (nonatomic, copy) NSString *template_render_count;//
@property (nonatomic, copy) NSString *template_size;//
@property (nonatomic, copy) NSString *template_time_long;//


@property (nonatomic, copy) NSString *style_name;//分类s

//请求视频模板详情
+ (void) requestTemplateDetailWithTemplateID:(NSNumber *)Template_id
                               SuccessHandle:(SuccessHandle)SuccessHandle
                               FailureHandle:(FailureHandle)FailureHandle;

@property (nonatomic, copy) NSString *template_create_timestamp;
@property (nonatomic, copy) NSString *template_preview_url;//
@property (nonatomic, copy) NSString *template_style_id;//
@property (nonatomic, strong) NSArray *combine_resources;//


//购买模板 付费
+ (void) requestTemplateChargeWithTemplateID:(NSNumber *)Template_id
                                    pay_type:(NSString *)pay_type
                               SuccessHandle:(SuccessHandle)SuccessHandle
                               FailureHandle:(FailureHandle)FailureHandle;

//上传图片素材
+ (void) requestUploadTemplateImage:(UIImage *)uploadImage
                           fileName:(NSString *)fileName
                       parameteName:(NSString *)parameterName
                      SuccessHandle:(SuccessHandle)SuccessHandle
                      FailureHandle:(FailureHandle)FailureHandle
                     progressHandle:(ProgressHandle)progress;




//获取我的收藏列表
+ (void) requestMyCollectionListWithStyle_id:(NSNumber *)style_id
                                   is_charge:(NSNumber *)is_charge
                                    is_short:(NSString *)is_short
                                        Page:(NSNumber *)page
                                      length:(NSNumber *)length
                               SuccessHandle:(SuccessHandle)successHandle
                               FailureHandle:(FailureHandle)failureHandle;


//收藏模板 取消模板
+ (void) requestCollectionDetailWithTemplate_id:(NSString *)template_id
                                   isCollection:(BOOL)isCollection//YES：收藏  NO：取消
                                  SuccessHandle:(SuccessHandle)SuccessHandle
                                  FailureHandle:(FailureHandle)FailureHandle;


//用户水印列表
+ (void) requestUserWaterListWithPage:(NSNumber *)page
                               length:(NSNumber *)length
                        SuccessHandle:(SuccessHandle)SuccessHandle
                        FailureHandle:(FailureHandle)FailureHandle;


//用户水印上传
+ (void) requestUserWaterUploadWithType:(NSString *)type
                               position:(NSNumber *)position
                                  image:(NSString *)image
                                   face:(NSString *)face
                                   size:(NSNumber *)size
                                  color:(NSString *)color
                                   text:(NSString *)text
                          SuccessHandle:(SuccessHandle)SuccessHandle
                          FailureHandle:(FailureHandle)FailureHandle;
//用户水印删除
+ (void) requestUserWaterDeleteWithTemplate_id:(NSString *)template_id
                                 SuccessHandle:(SuccessHandle)SuccessHandle
                                 FailureHandle:(FailureHandle)FailureHandle;


@property (nonatomic, copy) NSString *work_name;
@property (nonatomic, copy) NSString *make_status;
@property (nonatomic, copy) NSString *work_time_long;
@property (nonatomic, copy) NSString *work_size;
@property (nonatomic, copy) NSString *download_url;//下载地址
@property (nonatomic, copy) NSString *work_picture;//

//我的作品列表
+ (void) requestMyWorkListWithPage:(NSNumber *)page
                            length:(NSNumber *)length
                     SuccessHandle:(SuccessHandle)SuccessHandle
                     FailureHandle:(FailureHandle)FailureHandle;
//我的作品详情  or  删除
+ (void) requestMyWorkDetailWithTemplate_id:(NSString *)template_id
                                   isDetail:(BOOL)isDetail //YES：详情  NO：删除
                              SuccessHandle:(SuccessHandle)SuccessHandle
                              FailureHandle:(FailureHandle)FailureHandle;

//合成任务上传
+ (void) requestUploadTemplateTaskWithTemplate_id:(NSNumber *)template_id
                                        resources:(NSArray *)resources
                                    SuccessHandle:(SuccessHandle)SuccessHandle
                                    FailureHandle:(FailureHandle)FailureHandle;



@end
