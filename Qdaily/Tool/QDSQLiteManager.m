//
//  QDSQLiteManager.m
//  Qdaily
//
//  Created by Envy15 on 15/11/3.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSQLiteManager.h"
#import <FMDB.h>

@implementation QDSQLiteManager

+ (instancetype)sharedManager {
    static id _sharedInstance = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self openDB:@"feeds.sqlite"];
    }
    return self;
}

- (void)openDB: (NSString *)name {
    NSString *path = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).lastObject;
    NSString *filePath = [path stringByAppendingPathComponent:name];
    // 创建数据库对象
    _dbQueue = [FMDatabaseQueue databaseQueueWithPath:filePath];
    // 创建表
    [self createTable];
}

- (void)createTable {
    [_dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        // 表1,首页使用
        BOOL success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_HomeFeeds(\n\
                        postId INTEGER PRIMARY KEY, \n\
                        publish_time INTEGER , \n\
                        feedContent TEXT);"];
        if (!success) {
            QDLogVerbose(@"创建表失败");
            *rollback = YES;
        }
        
        // 表2,实验室使用
        success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_LabFeeds(\n\
                   postId INTEGER PRIMARY KEY, \n\
                   publish_time INTEGER , \n\
                   feedContent TEXT, \n\
                   genre INTEGER);"];
        if (!success) {
            QDLogVerbose(@"创建表失败");
            *rollback = YES;
        }
        
        // 表3,分类新闻使用(注意: category 为在菜单中的 ID, 而不是 post 的 Id)
        success = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS T_CategoryFeeds(\n\
                   postId INTEGER PRIMARY KEY, \n\
                   publish_time INTEGER , \n\
                   feedContent TEXT, \n\
                   category INTEGER);"];
        if (!success) {
            QDLogVerbose(@"创建表失败");
            *rollback = YES;
        }
    }];
}

@end
