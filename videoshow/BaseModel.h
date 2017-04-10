//
//  BaseModel.h
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Mantle.h"

typedef void(^SuccessHandle)(id responseObject);

typedef void(^FailureHandle)(NSError * error);

@interface BaseModel : MTLModel<MTLJSONSerializing>

- (void) serializeWithDictionary:(NSDictionary*)dictionary;
+ (NSDictionary *) pathsByPropertyKey;
+ (NSDictionary *) JSONKeyPathsByPropertyKey;

@end
