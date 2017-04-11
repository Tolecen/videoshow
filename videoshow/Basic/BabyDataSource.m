//
//  BabyDataSource.m
//  Babypai
//
//  Created by ning on 15/4/9.
//  Copyright (c) 2015年 Babypai. All rights reserved.
//

#import "BabyDataSource.h"
#import "AFNetworking.h"
#import "AESCrypt.h"
#import "MacroDefinition.h"

@implementation BabyDataSource


+ (BabyDataSource *)dataSource
{
    
    static dispatch_once_t onceToken;
    static BabyDataSource *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[BabyDataSource alloc]init];
    });
    
    return instance;
    
}

- (void)getData:(NSString *)URLString parameters:(id)parameters completion:(DataCompletionBlock)completionBlock
{
    
    if (completionBlock)
    {
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
        
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //很重要，去掉就容易遇到错误，暂时还未了解更加详细的原因
        
        NSString *url = [APIURL stringByAppendingString:URLString];
        
        NSLog(@"prepareUrl is %@", url);
        NSLog(@"parameters is %@", parameters);
        
        NSString *encodeString = [AESCrypt encrypt:parameters password:@"U1MjU1M0FDOUZ.Qz"];
       
        
        NSDictionary *dictionary = [NSDictionary dictionaryWithObjectsAndKeys:encodeString, @"fields", nil];
        
        [manager POST:url parameters:dictionary success:^(NSURLSessionDataTask *operation, id responseObject)
         {
             NSString *datas = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
             
             
             NSString *JSONString = [AESCrypt decrypt:[datas stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] password:@"U1MjU1M0FDOUZ.Qz"];
             
//             NSLog(@"AESCrypt decrypt: %@", JSONString);
             
             NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:[JSONString dataUsingEncoding:NSASCIIStringEncoding] options:NSJSONReadingAllowFragments error:nil];
             
             dispatch_async(dispatch_get_main_queue(), ^{
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 completionBlock(jsonData, JSONString);
             });
         }
             failure:^(NSURLSessionDataTask *operation, NSError *error)
         {
             NSLog(@"Error: %@", error);
             dispatch_async(dispatch_get_main_queue(), ^{
                 [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
                 NSString* errorString = error.localizedDescription;
                 if ([errorString length] == 0)
                     errorString = nil;
                 completionBlock(nil, errorString);
             });
         }];
    }
    
}


@end
