//
//  IndexMulti.h
//  Babypai
//
//  Created by ning on 16/5/25.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubjectInfo.h"
#import "Pin.h"

@interface IndexMulti : NSObject

@property(nonatomic, strong) NSMutableArray *subjects;
@property(nonatomic, strong)  NSMutableArray *hotPins;
@property (nonatomic, strong) NSMutableArray *tags;

@end
