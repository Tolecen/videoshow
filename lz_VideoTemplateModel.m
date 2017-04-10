//
//  lz_VideoTemplateModel.m
//  videoshow
//
//  Created by gutou on 2017/3/7.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "lz_VideoTemplateModel.h"
#import "BasePayController.h"

@implementation lz_VideoTemplateModel

+ (NSDictionary *) pathsByPropertyKey
{
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    [dic addEntriesFromDictionary:[super pathsByPropertyKey]];
    [dic addEntriesFromDictionary:@{@"template_id":@"id"}];
    return dic;
}

+ (void) requestWithStyleId:(NSNumber *)style_id
                   isCharge:(NSNumber *)is_charge
                  shortTime:(NSString *)shortTime
                  pageIndex:(NSNumber *)page
                     length:(NSNumber *)length
              SuccessHandle:(SuccessHandle)SuccessHandle
              FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *dict = @{@"style_id":style_id,
                           @"is_charge":is_charge,
                           @"short":shortTime,
                           @"page":page,
                           @"length":length,};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET URLString:kURLStringTemplates parameters:dict successHandle:^(id responseObject) {
        
//        NSLog(@"responseObject = %@",responseObject);
        
        NSArray *result = [MTLJSONAdapter modelsOfClass:[lz_VideoTemplateModel class] fromJSONArray:responseObject[@"data"] error:nil];
        
        SuccessHandle(result);
    } failureHandle:^(NSError *error) {
        FailureHandle(error);
    }];
}

//请求视频模板分类
+ (void) requestStyleWithSuccessHandle:(SuccessHandle)SuccessHandle
                         FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *dict = @{};
    [[AppRequestSender shareRequestSender] requestMethod:GET URLString:kURLStringTemplateStyles parameters:dict successHandle:^(id responseObject) {
        
        NSArray *result = [MTLJSONAdapter modelsOfClass:[lz_VideoTemplateModel class] fromJSONArray:responseObject[@"data"] error:nil];
        
        SuccessHandle(result);
    } failureHandle:^(NSError *error) {
        FailureHandle(error);
    }];
}

+ (void) requestTemplateDetailWithTemplateID:(NSNumber *)Template_id
                               SuccessHandle:(SuccessHandle)SuccessHandle
                               FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *dict = @{};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@",kURLStringTemplate,Template_id];
    
    [[AppRequestSender shareRequestSender] requestMethod:GET URLString:urlStr parameters:dict successHandle:^(id responseObject) {
        
        lz_VideoTemplateModel *model = [MTLJSONAdapter modelOfClass:[lz_VideoTemplateModel class] fromJSONDictionary:responseObject[@"data"] error:nil];
        SuccessHandle(model);
        
    } failureHandle:^(NSError *error) {
        FailureHandle(error);
    }];
}

//购买模板 付费
+ (void) requestTemplateChargeWithTemplateID:(NSNumber *)Template_id
                                    pay_type:(NSString *)pay_type
                               SuccessHandle:(SuccessHandle)SuccessHandle
                               FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *dict = @{@"channel":pay_type};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@/%@",kURLStringChargeTemplate,Template_id];
    
    [[AppRequestSender shareRequestSender] requestMethod:POST URLString:urlStr parameters:dict successHandle:^(id responseObject) {
        
        id dict = responseObject[@"data"];
        
        if ([dict isKindOfClass:[NSDictionary class]]) {
            if (((NSDictionary *)dict).allKeys.count != 0) {
                [[BasePayController shareInstance] WXpayProductWithOpenID:dict[@"appid"]
                                                              merchantsId:dict[@"partnerid"]
                                                                  orderId:dict[@"prepayid"]
                                                                 nonceStr:dict[@"noncestr"]
                                                                timeStamp:[dict[@"timestamp"] intValue]
                                                                  package:dict[@"package"]
                                                                     sign:dict[@"sign"]];
            }
        }
    } failureHandle:^(NSError *error) {
        FailureHandle(error);
    }];
}


+ (void) requestUploadTemplateImage:(UIImage *)uploadImage
                           fileName:(NSString *)fileName
                       parameteName:(NSString *)parameterName
                      SuccessHandle:(SuccessHandle)SuccessHandle
                      FailureHandle:(FailureHandle)FailureHandle
                     progressHandle:(ProgressHandle)progressHandle;
{
    NSDictionary *dict = @{};
    
    [[AppRequestSender shareRequestSender] uploadFileWithURLString:kURLStringTemplateUploadImage
                                                        parameters:dict
                                                         ImageData:UIImageJPEGRepresentation(uploadImage, 1)
                                                          fileName:fileName
                                                              name:parameterName
                                                          mimeType:@"image/jpg"
                                                     successHandle:^(id responseObject) {
                                                         
                                                         SuccessHandle(responseObject[@"data"]);
                                                     } failureHandle:^(NSError *error) {
                                                         FailureHandle(error);
                                                     } progressHandle:^(NSProgress *progress) {
                                                         progressHandle(progress);
                                                     }];
}


//获取我的收藏列表
+ (void) requestMyCollectionListWithStyle_id:(NSNumber *)style_id
                                   is_charge:(NSNumber *)is_charge
                                    is_short:(NSString *)is_short
                                        Page:(NSNumber *)page
                                      length:(NSNumber *)length
                               SuccessHandle:(SuccessHandle)successHandle
                               FailureHandle:(FailureHandle)failureHandle;
{
    NSDictionary *param;
    if (style_id && is_charge && is_short) {
        param = @{@"style_id":style_id,
                  @"is_charge":is_charge,
                  @"short":is_short,
                  @"page":page,
                  @"length":length};
    }else {
        param = @{@"page":page,
                  @"length":length};
    }
    
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringMyCollectionList
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               NSArray *result = [MTLJSONAdapter modelsOfClass:[lz_VideoTemplateModel class] fromJSONArray:responseObject[@"data"] error:nil];
                                               successHandle(result);
                                           } failureHandle:^(NSError *error) {
                                               failureHandle(error);
                                           }];
}

//收藏模板 取消收藏模板
+ (void) requestCollectionDetailWithTemplate_id:(NSString *)template_id
                                   isCollection:(BOOL)isCollection//YES：收藏  NO：取消
                                  SuccessHandle:(SuccessHandle)SuccessHandle
                                  FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{@"template_id":template_id};
    
    [[AppRequestSender shareRequestSender] requestMethod:isCollection?DELETE:POST
                                               URLString:kURLStringCollectionTemplate
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               NSString *status = [responseObject valueForKey:@"message"];
                                               
                                               SuccessHandle(status);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}

//用户水印列表
+ (void) requestUserWaterListWithPage:(NSNumber *)page
                               length:(NSNumber *)length
                        SuccessHandle:(SuccessHandle)SuccessHandle
                        FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{@"page":page,
                            @"length":length};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringMyWatermarkList
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                           } failureHandle:^(NSError *error) {
                                               
                                           }];
}

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
{
    NSDictionary *param = @{@"type":type,
                            @"position":position,
                            @"image":image,
                            @"face":face,
                            @"size":size,
                            @"color":color,
                            @"text":text,};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringWatermarkUploadOrDelete
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               SuccessHandle(responseObject[@"data"]);
                                           } failureHandle:^(NSError *error) {
                                               
                                           }];
}
//用户水印删除
+ (void) requestUserWaterDeleteWithTemplate_id:(NSString *)template_id
                                 SuccessHandle:(SuccessHandle)SuccessHandle
                                 FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:DELETE
                                               URLString:kURLStringWatermarkUploadOrDelete
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                           } failureHandle:^(NSError *error) {
                                               
                                           }];
}
//我的作品列表
+ (void) requestMyWorkListWithPage:(NSNumber *)page
                            length:(NSNumber *)length
                     SuccessHandle:(SuccessHandle)SuccessHandle
                     FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{@"page":page,
                            @"length":length};
    
    [[AppRequestSender shareRequestSender] requestMethod:GET
                                               URLString:kURLStringMyWorkList
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               NSArray *result = [MTLJSONAdapter modelsOfClass:[lz_VideoTemplateModel class] fromJSONArray:responseObject[@"data"] error:nil];
                                               
                                               SuccessHandle(result);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}
//我的作品详情  or  删除
+ (void) requestMyWorkDetailWithTemplate_id:(NSString *)template_id
                                   isDetail:(BOOL)isDetail //YES：详情  NO：删除
                              SuccessHandle:(SuccessHandle)SuccessHandle
                              FailureHandle:(FailureHandle)FailureHandle;
{
    NSDictionary *param = @{};
    
    [[AppRequestSender shareRequestSender] requestMethod:isDetail?GET:DELETE
                                               URLString:[NSString stringWithFormat:@"%@/%@",kURLStringMyWorkDetailOrDelete,template_id]
                                              parameters:param
                                           successHandle:^(id responseObject) {
                                               
                                               if (isDetail == YES) {
                                                
                                                   lz_VideoTemplateModel *model = [MTLJSONAdapter modelOfClass:[lz_VideoTemplateModel class] fromJSONDictionary:responseObject[@"data"] error:nil];
                                                   SuccessHandle(model);
                                                   
                                               }else if (isDetail == NO) {
                                                   
                                                   SuccessHandle(responseObject);
                                               }else {}
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}


//合成任务上传
+ (void) requestUploadTemplateTaskWithTemplate_id:(NSNumber *)template_id
                                        resources:(NSArray *)resources
                                    SuccessHandle:(SuccessHandle)SuccessHandle
                                    FailureHandle:(FailureHandle)FailureHandle;
{
    
    NSDictionary *parame = @{@"template_id":template_id,
                             @"resources":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:resources options:NSJSONWritingPrettyPrinted error:nil] encoding:NSUTF8StringEncoding]};
    
    [[AppRequestSender shareRequestSender] requestMethod:POST
                                               URLString:kURLStringMyWorkDetailOrDelete
                                              parameters:parame
                                           successHandle:^(id responseObject) {
                                               
                                               SuccessHandle(responseObject);
                                           } failureHandle:^(NSError *error) {
                                               FailureHandle(error);
                                           }];
}






@end
