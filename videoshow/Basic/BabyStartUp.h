//
//  BabyStartUp.h
//  Babypai
//
//  Created by ning on 16/4/10.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MacroDefinition.h"

@interface BabyStartUp : NSObject

@property (nonatomic, strong, readonly) UINavigationController *rootViewController;

+ (instancetype) appStartUp;

@end
