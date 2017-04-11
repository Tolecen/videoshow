//
//  SearchAllInfoList.h
//  Buole
//
//  Created by ning on 16/7/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SearchAllInfo.h"

@interface SearchAllInfoList : NSObject

@property (nonatomic, assign) int msg;
@property (nonatomic, assign) long timestamp;
@property (nonatomic, strong) NSString *error;
@property (nonatomic, strong) SearchAllInfo *info;

@end
