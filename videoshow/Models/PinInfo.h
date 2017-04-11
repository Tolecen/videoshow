//
//  PinInfo.h
//  Babypai
//
//  Created by ning on 16/5/11.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Pin.h"
@interface PinInfo : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) Pin *info;

@end
