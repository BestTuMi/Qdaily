//
//  QDSQLiteManager.h
//  Qdaily
//
//  Created by Envy15 on 15/11/3.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class FMDatabaseQueue;

@interface QDSQLiteManager : NSObject
/** 多线程操作时的数据库对象 */
@property (nonatomic, strong)  FMDatabaseQueue *dbQueue;
+ (instancetype)sharedManager;
@end
