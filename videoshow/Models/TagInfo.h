//
//  TagInfo.h
//  Babypai
//
//  Created by ning on 16/5/16.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Tag.h"

@interface TagInfo : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) Tag *info;

@end
