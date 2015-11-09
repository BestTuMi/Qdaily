//
//  QDFeedCacheTool.m
//  Qdaily
//
//  Created by Envy15 on 15/11/3.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedCacheTool.h"
#import "QDSQLiteManager.h"
#import <FMDB.h>
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDHomeLabFeedViewController.h"

@implementation QDFeedCacheTool

+ (void)cacheFeeds:(NSDictionary *)dict {
    // dict[@"feeds"]
    [[QDSQLiteManager sharedManager].dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // lasttime 是数组最后一个的 publish_time(除了首页第一页是倒数第二个)
        // 取出list 数组(包含新闻的数组)
        NSArray *feeds = dict[@"feeds"][@"list"];
        for (NSDictionary *feed in feeds) {
            // 取出 post id 作为主键
            NSInteger postId = [feed[@"post"][@"id"] integerValue];
            
            // 取出 publishTime 存储
            NSInteger publish_time = [feed[@"post"][@"publish_time"] integerValue];
            
            // 取出 genre 存储
            NSInteger genre = [feed[@"post"][@"genre"] integerValue];
            
            // 取出 category 存储
            NSInteger category = [feed[@"post"][@"category"][@"id"] integerValue];
            
            // 将内容转换为文本存储(feed 整体)
            NSData *data = [NSJSONSerialization dataWithJSONObject:feed options:NSJSONWritingPrettyPrinted error:nil];
            NSString *feedContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            // sql 语句,插入数据,保存
            NSString *sql = @"INSERT INTO T_Feeds (postId, publish_time, genre, category, feedContent)\n\
                            VALUES\n\
                            (?, ?, ?, ?, ?);";
            
            BOOL success = [db executeUpdate:sql withArgumentsInArray:@[@(postId), @(publish_time), @(genre), @(category), feedContent]];
            
            if (!success) {
                // 事务回滚
                *rollback = YES;
            }
        }
    }];
}

+ (void)loadFeedsCachesWithLastTime: (NSString *)last_time class: (Class)class category: (NSInteger)category finished: (void (^)(NSArray *feeds))finished {
    if ([last_time integerValue] == 0) { // 第一次加载,总是获取网络数据
        finished(nil);
        return;
    }
    
    // 加载更多时, publish_time <= last_time,降序排列,限制12条
    NSMutableString *sql = [NSMutableString string];
    [sql appendString: @"SELECT *FROM T_Feeds WHERE publish_time < ? "];
    
    // 保存查询条件的数组
    NSMutableArray *filters = [NSMutableArray array];
  
    // 需要按照 genre 查询数据(好奇心实验室页面)
    if (class == [QDHomeLabFeedViewController class]) {
        [sql appendString:@"AND genre IN (QDGenrePaper, QDGenreReport, QDGenreVote) "];
    }
    
    // 需要按照分类查询数据
    if (category) {
        [sql appendString:@"AND category = ? "];
        // 保存参数
        [filters addObject:@(category)];
    }
    
    // 排序条件
    [sql appendString:@"ORDER BY publish_time DESC LIMIT 12"];
    
    // 执行 sql 语句
    [[QDSQLiteManager sharedManager].dbQueue inDatabase:^(FMDatabase *db) {
        
        // 拼接参数并执行 sql 语句
        FMResultSet *recordSet = [db executeQuery:sql withArgumentsInArray:filters];
        
        // 保存字典数组
        NSMutableArray *arrayM = [NSMutableArray array];
        
        while ([recordSet next]) {
            QDLogVerbose(@"数据来自本地缓存");
            NSString *feedContent = [recordSet stringForColumn:@"feedContent"];
            // 转为字典
            NSData *data = [feedContent dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *feedDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            // 字典转模型
            QDFeed *feed = [QDFeed objectWithKeyValues:feedDict];
            [arrayM addObject:feed];
        }
        
        finished([arrayM copy]);
    }];
}

@end
