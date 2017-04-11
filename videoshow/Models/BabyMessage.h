//
//  BabyMessage.h
//  Babypai
//
//  Created by ning on 16/5/29.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BabyMessage : NSObject

@property(nonatomic, assign) int message_id;
@property(nonatomic, assign) int type;
@property(nonatomic, strong) NSString *topic;
@property(nonatomic, strong) NSString *message;
@property(nonatomic, assign) int ref_id;

@end
