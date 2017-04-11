//
//  PinBoard.h
//  CollectionTest
//
//  Created by ning on 15/4/8.
//  Copyright (c) 2015年 ning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PinBoard : NSObject

@property (nonatomic, assign) long board_id;
@property (nonatomic, assign) long user_id;
@property (nonatomic, copy) NSString *title;
//@property (nonatomic, copy) NSString *description;
@property (nonatomic, assign) int seq;
@property (nonatomic, assign) long pin_count;
@property (nonatomic, assign) long follow_count;
@property (nonatomic, assign) long created_at;
@property (nonatomic, assign) long updated_at;
@property (nonatomic, assign) int is_private;

@end
