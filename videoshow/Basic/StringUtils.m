//
//  StringUtils.m
//  Babypai
//
//  Created by ning on 16/4/17.
//  Copyright © 2016年 Babypai. All rights reserved.
//

#import "StringUtils.h"

@implementation StringUtils


+ (NSString *)getDatePath
{
    // 实例化NSDateFormatter
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    // 设置日期格式
    [formatter setDateFormat:@"yyyy/MM/dd"];
    // 获取当前日期
    NSDate *currentDate = [NSDate date];
    NSString *currentDateString = [formatter stringFromDate:currentDate];
    return currentDateString;
}

+ (NSString *)getDatePathWithFile:(NSString *)suffix
{
    return [NSString stringWithFormat:@"/{year}/{mon}/{day}/face_{filemd5}{.suffix}"];;
}

+ (bool)isEmpty:(NSString *)str
{
    if (str == nil || str.length == 0) {
        return true;
    }
    
    return false;
}

/*邮箱验证*/
+ (bool)isEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:email];
}

/*手机号码验证 */
+ (bool)isMobile:(NSString *)mobile
{
    
    NSString *phoneRegex = @"((^(13|14|15|18|17)[0-9]{9}$)|(^0[1,2]{1}\\d{1}-?\\d{8}$)|(^0[3-9] {1}\\d{2}-?\\d{7,8}$)|(^0[1,2]{1}\\d{1}-?\\d{8}-(\\d{1,4})$)|(^0[3-9]{1}\\d{2}-? \\d{7,8}-(\\d{1,4})$))";
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",phoneRegex];
    //    NSLog(@"phoneTest is %@",phoneTest);
    return [phoneTest evaluateWithObject:mobile];
}

/*车牌号验证 */
+ (bool)isCarNo:(NSString* )carNo
{
    NSString *carRegex = @"^[A-Za-z]{1}[A-Za-z_0-9]{5}$";
    NSPredicate *carTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",carRegex];
    NSLog(@"carTest is %@",carTest);
    return [carTest evaluateWithObject:carNo];
}

+ (long)toLong:(NSString *)str
{
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:str];
    return (long)[myNumber longLongValue];
}

+ (int)videoTime:(long)video_time
{
    int time = 0;
    int time_s = (int) video_time / 1000;
    if (time_s < 1)
        time = 1;
    else {
        time = time_s;
        int time_d = (int) video_time % 1000;
        if (time_d > 500)
            time = time + 1;
    }
    return time;
}


@end
