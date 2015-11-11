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

+ (void)cacheHomeFeeds:(NSDictionary *)dict {
    [self cacheFeeds:dict filter:nil toTable:@"T_HomeFeeds"];
}

+ (void)cacheLabFeeds:(NSDictionary *)dict {
    [self cacheFeeds:dict filter:nil toTable:@"T_LabFeeds"];
}

+ (void)cacheCategoryFeeds:(NSDictionary *)dict categoryId: (NSInteger)categoryId {
    [self cacheFeeds:dict filter:@(categoryId) toTable:@"T_CategoryFeeds"];
}

+ (void)cacheFeeds:(NSDictionary *)dict filter: (id)filter toTable: (NSString *)table {
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
            
            // 将内容转换为文本存储(feed 整体)
            NSData *data = [NSJSONSerialization dataWithJSONObject:feed options:NSJSONWritingPrettyPrinted error:nil];
            NSString *feedContent = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            // sql 语句,插入数据,保存
            NSString *sql = @"INSERT INTO T_HomeFeeds(postId, publish_time, feedContent) \n\
                                VALUES(?, ?, ?)";
            
            NSString *tableName = @"T_HomeFeeds";
            
            // 更新 sql 的语句,如果不存在, changes()函数返回值为0
            NSString *updateSql = [NSString stringWithFormat:@"UPDATE %@ SET feedContent = '%@' WHERE postId = %zd", tableName, feedContent, postId];
            
            // 参数数组
            NSMutableArray *arguments = [NSMutableArray array];
            [arguments addObjectsFromArray:@[@(postId), @(publish_time), feedContent]];
            
            // 实验室页面
            if ([table containsString:@"Lab"]) {
                // 取出 genre 存储
                NSInteger genre = [feed[@"post"][@"genre"] integerValue];
                // 取出参加人数
                NSInteger record_count = [feed[@"post"][@"record_count"] integerValue];
                sql = @"INSERT INTO T_LabFeeds(postId, publish_time, feedContent, genre, record_count) \n\
                            VALUES(?, ?, ?, ?, ?)";
                [arguments addObject:@(genre)];
                [arguments addObject:@(record_count)];
                tableName = @"T_LabFeeds";
                
                updateSql = [NSString stringWithFormat:@"UPDATE T_LabFeeds SET feedContent = '%@' WHERE postId = %zd;UPDATE T_LabFeeds SET record_count = %zd WHERE postId = %zd;", feedContent, postId, record_count, postId];
            }

            // 分类新闻页面
            if ([table containsString:@"Category"]) {
                sql = @"INSERT INTO T_CategoryFeeds(postId, publish_time, feedContent, category) \n\
                        VALUES(?, ?, ?, ?)";
                [arguments addObject:filter];
                tableName = @"T_CategoryFeeds";
            }
            
           
            BOOL success = [db executeStatements:updateSql];
            
            // 没有变化表示没有，进行插入
            if (db.changes == 0) {
                success = [db executeUpdate:sql withArgumentsInArray:arguments];
            }
            
            if (!success) {
                // 事务回滚
                *rollback = YES;
            }
        }
    }];
}


+ (void)loadHomeFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed {
    [self loadFeedsCachesFromTable:@"T_HomeFeeds" lastTime:last_time filter:filter finished:^(NSArray *feeds) {
        completed(feeds);
    }];
}

+ (void)loadLabFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed {
    [self loadFeedsCachesFromTable:@"T_LabFeeds" lastTime:last_time filter:filter finished:^(NSArray *feeds) {
        completed(feeds);
    }];
}

+ (void)loadCategoryFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed {
    [self loadFeedsCachesFromTable:@"T_CategoryFeeds" lastTime:last_time filter:filter finished:^(NSArray *feeds) {
        completed(feeds);
    }];
}


+ (void)loadFeedsCachesFromTable: (NSString *)table lastTime: (NSString *)last_time filter: (id)filter finished: (void (^)(NSArray *feeds))finished {
    if ([last_time integerValue] == 0) { // 第一次加载,总是获取网络数据
        finished(nil);
        return;
    }
    
    // 加载更多时, publish_time <= last_time,降序排列,限制12条
    
    // 保存查询条件的数组
    NSMutableArray *filters = [NSMutableArray array];
    
    NSMutableString *sql = [NSMutableString string];
    if ([table containsString:@"Home"]) {
        [sql appendString: @"SELECT *FROM T_HomeFeeds WHERE publish_time < ? "];
        [filters addObject:last_time];
    }
  
    // 需要按照 genre 查询数据(好奇心实验室页面)
    if ([table containsString:@"Lab"]) {
        [sql appendString: @"SELECT *FROM T_LabFeeds WHERE publish_time < ? "];
        [filters addObject:last_time];
    }
    
    // 需要按照分类查询数据
    if ([table containsString:@"Category"]) {
        
        [sql appendString: @"SELECT *FROM T_CategoryFeeds WHERE publish_time < ? "];
        [filters addObject:last_time];
        
        [sql appendString:@"AND category = ? "];
        [filters addObject:filter];
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
