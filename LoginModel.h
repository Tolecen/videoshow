//
//  LoginModel.h
//  videoshow
//
//  Created by gutou on 2017/3/8.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "BaseModel.h"

@interface LoginModel : BaseModel

@property (nonatomic, copy) NSString *user_id;
@property (nonatomic, copy) NSString *token;

+ (void) loginWithCode:(NSString *)code
         SuccessHandle:(SuccessHandle)SuccessHandle
         FailureHandle:(FailureHandle)FailureHandle;

+ (void) testGetLoginCodeWithSuccessHandle:(SuccessHandle)SuccessHandle
                             FailureHandle:(FailureHandle)FailureHandle;
@end
