//
//  QDQTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeFeedArticleViewController.h"
#import "QDCollectionView.h"

@interface QDHomeFeedArticleViewController ()

@end

@implementation QDHomeFeedArticleViewController

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/homes/index/%@.json?", self.last_time];
}

#pragma mark - 加载缓存或网络数据
- (void)loadMoreNews {
    // 先从本地获取
    [QDFeedCacheTool loadLabFeedsCachesWithLastTime:self.last_time filter:nil completed:^(NSArray *feeds) {
        if (feeds.count == 0) {
            // 本地没有,从网络获取
            [self loadMoreFeedsFromNetWork];
        }
    }];
}

#pragma mark - 处理数据并缓存
- (void)handleFeeds:(NSDictionary *)responseObject pullingDown:(BOOL)pullingDown {
    [super handleFeeds:responseObject pullingDown:pullingDown];
    [QDFeedCacheTool cacheHomeFeeds:responseObject[@"response"]];
}

@end
