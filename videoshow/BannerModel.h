//
//  BannerModel.h
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseModel.h"

@interface BannerModel : BaseModel

+ (void)requestBannerModelOfCompletionHandler:(SuccessHandle)successHandler
                                  failHandler:(FailureHandle)failHandler;

@property (nonatomic, copy) NSURL    *Img;
@property (nonatomic, copy) NSString *Intro;
@property (nonatomic, copy) NSURL    *ImgUrl;

@property (nonatomic, copy) NSString *image_url;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *ad_id;
@property (nonatomic, copy) NSString *position;

@end
