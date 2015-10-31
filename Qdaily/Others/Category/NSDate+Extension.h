//
//  NSDate+Extension.h
//  budejie
//
//  Created by Envy15 on 15/9/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
- (BOOL)isThisYear;
- (BOOL)isYesterday;
- (BOOL)isToday;
- (NSDateComponents *)intervalToNow;
- (NSDateComponents *)intervalToDate: (NSDate *)date;
@end
