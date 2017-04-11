//
//  BabyDataSource.h
//  Babypai
//
//  Created by ning on 15/4/9.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^DataCompletionBlock)(NSDictionary* data, NSString* errorString);

@interface BabyDataSource : NSObject

+ (BabyDataSource *)dataSource;

- (void)getData:(NSString *)URLString parameters:(id)parameters completion:(DataCompletionBlock)completionBlock;

@end
