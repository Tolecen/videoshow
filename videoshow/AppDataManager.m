//
//  AppDataManager.m
//  videoshow
//
//  Created by gutou on 2017/2/28.
//  Copyright © 2017年 mapboo. All rights reserved.
//

#import "AppDataManager.h"

#import "FMDB.h"

//登陆通知
NSString * const appDidLogoutNotification = @"appDidLogoutNotification";
//登出通知
NSString * const appDidLoginNotification = @"appDidLoginNotification";

static AppDataManager* instance;

@interface AppDataManager ()

@property (nonatomic, readonly) NSUserDefaults *userDefaults;
@property (nonatomic, readonly) FMDatabase *BaseSQLite;

@end

@implementation AppDataManager

+(instancetype) defaultManager
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[AppDataManager alloc] init];
    });
    return instance;
}

//写入本地
- (NSUserDefaults *) userDefaults
{
    return [NSUserDefaults standardUserDefaults];
}

//设置id
- (void) setIdentifier:(NSString *)identifier
{
    if (!identifier) {
        [[NSNotificationCenter defaultCenter] postNotificationName:appDidLogoutNotification object:nil];
        //如果id为空，移除id键值对
        [self.userDefaults removeObjectForKey:@"identifier"];
        [self.userDefaults synchronize];
        //id被清空
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:appDidLoginNotification object:nil];
    
    //如果有id 设置id键
    [self.userDefaults setObject:identifier forKey:@"identifier"];

    //取出key键id下的value
    NSDictionary* dic = [self.userDefaults objectForKey:identifier];
    if (!dic) {
        //如果没有字典，创建一个字典重新写入本地
        dic = [NSDictionary dictionary];
        [self.userDefaults setObject:dic forKey:identifier];
    }
    [self.userDefaults synchronize];
}

- (NSString *) identifier
{
    return [self.userDefaults objectForKey:@"identifier"];
}

-(void) setUserId:(NSString *)userId
{
    //如果没有id，未登录状态，不能设置userid
    if (![self identifier]) {
        return;
    }
    //如果有id，根据key键id取出对应的字典，深拷贝
    NSMutableDictionary* dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    //将userid写入字典
    [dic setObject:userId forKey:@"userId"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

-(NSString *) userId
{
    //如果没有id，未登录状态，返回空
    if (![self identifier]) {
        return nil;
    }
    //如果有id，先根据key键id取字典，根据key键userid取value
    return [self.userDefaults objectForKey:[self identifier]][@"userId"];
}

-(void) setPhoneNumber:(NSString *)phoneNumber
{
    //如果没有id，未登录状态，不能设置userid
    if (![self identifier]) {
        return;
    }
    //如果有id，根据key键id取出对应的字典，深拷贝
    NSMutableDictionary* dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    //将userid写入字典
    [dic setObject:phoneNumber forKey:@"phoneNumber"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

-(NSString *) phoneNumber
{
    return [self.userDefaults objectForKey:[self identifier]][@"phoneNumber"];
}

- (void) setUser_vip:(NSString *)user_vip
{
    [self settingSetterFunctionWithKey:@"user_vip" value:user_vip];
}



- (NSString *) user_vip
{
    return [self.userDefaults objectForKey:[self identifier]][@"user_vip"];
}

-(void) setName:(NSString *)name
{
    if (![self identifier]) {
        return;
    }
    NSMutableDictionary* dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    if(name.length >0){
        [dic setObject:name forKey:@"name"];
    }else{
        [dic removeObjectForKey:@"name"];
    }
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

-(NSString *) name
{
    if (![self identifier]) {
        return nil;
    }
    NSDictionary* dic = [self.userDefaults objectForKey:[self identifier]];
    return dic[@"name"];
}

- (void) setPayPassWord:(NSString *)payPassWord
{
    if (![self identifier])
    {
        return;
    }
    NSMutableDictionary *dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    [dic setObject:payPassWord forKey:@"payPassWord"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

- (NSString *) payPassWord
{
    if (![self identifier])
    {
        return nil;
    }
    NSDictionary *dic = [self.userDefaults objectForKey:[self identifier]];
    return dic[@"payPassWord"];
}

- (void) setMoneyCount:(NSString *)moneyCount
{
    if (![self identifier]) {
        return;
    }
    NSMutableDictionary *dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    [dic setObject:moneyCount forKey:@"moneyCount"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

//账户余额
- (NSString *) moneyCount
{
    if (![self identifier]) {
        return nil;
    }
    NSDictionary *dic = [self.userDefaults objectForKey:[self identifier]];
    return dic[@"moneyCount"];
}

- (void) setDevice_token:(NSString *)device_token
{
    if (![self identifier]) {
        return;
    }
    NSMutableDictionary *dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    [dic setObject:device_token forKey:@"device_token"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

- (NSString *) device_token
{
    if (![self identifier]) {
        return nil;
    }
    NSDictionary *dic = [self.userDefaults objectForKey:[self identifier]];
    return dic[@"device_token"];
}

- (void) setUser_image:(NSData *)user_image
{
    if (![self identifier]) {
        return;
    }
    NSMutableDictionary *dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    [dic setObject:user_image forKey:@"user_image"];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}

- (NSData *) user_image
{
    if (![self identifier]) {
        return nil;
    }
    NSDictionary *dic = [self.userDefaults objectForKey:[self identifier]];
    return dic[@"user_image"];
}

#pragma mark - 状态标识 -
-(BOOL) hasLogin
{
    return [self identifier].length?YES:NO;
}

- (BOOL) hasVip
{
    return [self user_vip].length?YES:NO;
}

-(void) logout
{
    [self setIdentifier:nil];
}

-(void) loginWithIdentifier:(NSString *)identifier
{
    if (identifier) {
        [self setIdentifier:identifier];
        [[NSNotificationCenter defaultCenter] postNotificationName:appDidLoginNotification object:nil];
    }
}
#pragma mark -------

//设置setter方法
- (void) settingSetterFunctionWithKey:(NSString *)key value:(NSString *)value
{
    //如果没有id，未登录状态，不能设置userid
    if (![self identifier]) {
        return;
    }
    //如果有id，根据key键id取出对应的字典，深拷贝
    NSMutableDictionary* dic = [[self.userDefaults objectForKey:[self identifier]] mutableCopy];
    //将userid写入字典
    [dic setObject:value forKey:key];
    [self.userDefaults setObject:dic forKey:[self identifier]];
    [self.userDefaults synchronize];
}


#pragma mark - 公共资源 -
//公共访问资源
- (void) setPublicData:(NSString *)publicData {
    if (!publicData) {
        [self.userDefaults removeObjectForKey:[self publicData]];
        [self.userDefaults synchronize];
        return;
    }
    NSMutableDictionary *dic = [[self.userDefaults valueForKey:[self publicData]] mutableCopy];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
        [self.userDefaults setObject:dic forKey:[self publicData]];
    }
    [self.userDefaults synchronize];
}
- (NSString *) publicData
{
    return @"publicData";
}

- (void) setAdDic:(NSDictionary *)adDic
{
    NSMutableDictionary *dict = [[self.userDefaults valueForKey:[self publicData]] mutableCopy];
    if (adDic != nil) {
        
        [dict setValue:adDic forKey:@"adDic"];
    }else {
        [dict removeObjectForKey:@"adDic"];
    }
    [self.userDefaults setObject:dict forKey:[self publicData]];
    [self.userDefaults synchronize];
}

- (NSDictionary *) adDic
{
    NSDictionary *dict = [self.userDefaults objectForKey:[self publicData]];
    return dict[@"adDic"];
}

#pragma mark - 数据库相关内容 -
- (FMDatabase *) BaseSQLite
{
    return [FMDatabase databaseWithPath:[self videoSqlite]];
}

//fetch document
- (NSString *) documentsDirectory
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

//videoShow's Path
- (NSString *) videoSqlite
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"video.sqlite"];
}

- (NSString *) adArrPath
{
    return [[self documentsDirectory] stringByAppendingPathComponent:@"adArrPath"];
}









@end
