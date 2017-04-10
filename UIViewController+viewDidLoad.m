//
//  UIViewController+viewDidLoad.m
//  videoshow
//
//  Created by gutou on 2017/2/27.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "UIViewController+viewDidLoad.h"
#import <objc/runtime.h>

// pointer of _VIMP by custom
typedef void (* _VIMP)(id, SEL, ...);

@implementation UIViewController (viewDidLoad)

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // get system viewDidLoad method
        Method viewDidLoad = class_getInstanceMethod(self, @selector(viewDidLoad));
        
        // get the system implementation of viewDidLoad
        _VIMP viewDidLoad_VIMP = (_VIMP)method_getImplementation(viewDidLoad);
        
        // resetter the  system implementation of viewDidLoad
        method_setImplementation(viewDidLoad, imp_implementationWithBlock(^ (id target , SEL action){
            
            // the system viewDidLoad method
            viewDidLoad_VIMP(target , @selector(viewDidLoad));
            
            
            // the new add NSLog method
            NSLog(@"小视秀log :%@ did load",target);
        }));
        
        
    });
}


@end
