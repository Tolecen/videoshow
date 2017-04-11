//
//  IndexMultiInfo.h
//  Babypai
//
//  Created by ning on 16/5/25.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IndexMulti.h"

@interface IndexMultiInfo : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) IndexMulti *info;

@end
