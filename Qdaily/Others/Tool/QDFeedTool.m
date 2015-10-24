//
//  QDFeedTool.m
//  Qdaily
//
//  Created by Envy15 on 15/10/11.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedTool.h"

@implementation QDFeedTool

+ (instancetype)sharedFeedTool {
    static QDFeedTool *_sharedFeedTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFeedTool = [[self alloc] initWithBaseURL:QDBaseURL];
    });
    return _sharedFeedTool;
}

/// 取消任务
- (void)cancel {
    [[QDFeedTool sharedFeedTool].tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)setupFeedsWithUrl: (NSString *)urlStr parameters: (NSDictionary *)parameters finished:(void (^)())finished {
    // 取消之前的请求
    [[QDFeedTool sharedFeedTool] cancel];

    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        QDLogVerbose(@"%@", responseObject);
        // 处理错误
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (error) {
            QDLogVerbose(@"%@", error);
        }
    }];
}

/**
- (void)setupFeeds {
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 重置lasttime,返回新数据
    self.last_time = nil;
    
    [self.manager GET:self.currentRequestUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        QDLogVerbose(@"%@", responseObject);
        
        // 移除模型数组所有元素
        [self.feeds removeAllObjects];
        [self.news removeAllObjects];
        self.banners = nil;
        
        // 保存属性上拉加载发送
        self.last_time = responseObject[@"response"][@"feeds"][@"last_time"];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 轮播图
        self.banners = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"banners"][@"list"]];
        
        // 将轮播图以数组形式添加到 collectionView 数据源,目的是方便计算布局
        // 注意:子类肯能没有轮播图
        if (self.banners.count) {
            [self.feeds addObject:self.banners];
        }
        
        // 新闻
        NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
        [self.news addObjectsFromArray:news];
        // 添加到 collectionView 数据源
        [self.feeds addObjectsFromArray:news];
        
        // 将模型传递给 Layout 对象进行布局设置
        self.flowLayout.feeds = self.feeds;
        
        // 刷新CollectionView
        [self.collectionView reloadData];
        [self.collectionView.header endRefreshing];
        
        if (!self.has_more) { // 表示没有数据了,隐藏 Footer
            self.collectionView.footer.hidden = YES;
        } else {
            // 结束刷新
            [self.collectionView.footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.collectionView.header endRefreshing];
    }];
}
 */

@end
