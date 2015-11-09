//
//  QDFeedCacheTool.h
//  Qdaily
//
//  Created by Envy15 on 15/11/3.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDFeedCacheTool : NSObject
+ (void)cacheFeeds: (NSDictionary *)dict;
+ (void)loadFeedsCachesWithLastTime: (NSString *)last_time genre: (NSInteger)genre category: (NSInteger)category finished: (void (^)(NSArray *feeds))finished;
@end
