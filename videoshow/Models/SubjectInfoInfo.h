//
//  SubjectInfoInfo.h
//  Babypai
//
//  Created by ning on 16/5/27.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubjectInfo.h"

@interface SubjectInfoInfo : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) SubjectInfo *info;

@end
