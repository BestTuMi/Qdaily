//
//  NSDate+Extension.m
//  budejie
//
//  Created by Envy15 on 15/9/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "NSDate+Extension.h"

@implementation NSDate (Extension)

- (BOOL)isThisYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy";
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear;
    NSDateComponents *selfDateComps = [calendar components:unit fromDate:self];
    NSDateComponents *nowDateComps = [calendar components:unit fromDate:[NSDate date]];
    
    return selfDateComps.year == nowDateComps.year;
}

- (BOOL)isToday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    // 获得当前日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *selfDateComps = [calendar components:unit fromDate:self];
    NSDateComponents *nowDateComps = [calendar components:unit fromDate:[NSDate date]];
    
    return selfDateComps.year == nowDateComps.year &&
            selfDateComps.month == nowDateComps.month &&
            selfDateComps.day == nowDateComps.day;
}

- (BOOL)isYesterday {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSDate *date1 = [formatter dateFromString:@"2015-07-08 00:01:00"];
    
    // 获得当前日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *selfDateComps = [calendar components:unit fromDate:self];
    NSDateComponents *nowDateComps = [calendar components:unit fromDate:date1];
    
    return selfDateComps.year == nowDateComps.year &&
    selfDateComps.month == nowDateComps.month &&
    selfDateComps.day == nowDateComps.day - 1;
}
// 4.如果是今天,显示 N 小时前      isToday = YES
// 5.如果是1小时内,显示刚刚        最后比较小时
- (NSDateComponents *)intervalToDate: (NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
    // 获得当前日历对象
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    return [calendar components:unit fromDate:self toDate:date options:0];
}

- (NSDateComponents *)intervalToNow {
    return [self intervalToDate:[NSDate date]];
}


@end
