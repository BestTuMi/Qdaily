//
//  QDCategoryFeedViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCategoryFeedViewController.h"
#import "QDCustomNaviBar.h"
#import "QDSideBarCategory.h"
#import "QDCollectionView.h"
#import "QDFeedLayout.h"
#import "QDFeedCacheTool.h"
#import "QDFeed.h"
#import <MJRefresh.h>

@interface QDCategoryFeedViewController ()

/** 自定义导航条 */
@property (nonatomic, weak)  QDCustomNaviBar *naviBar;
/** 所有分类 */
@property (nonatomic, strong) NSMutableDictionary *categories;

@end

@implementation QDCategoryFeedViewController

// 请求地址拼接
- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/categories/index/%@/%@.json?", self.category.ID, self.last_time] ;
}

- (NSDictionary *)parameters {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavi];

}

#pragma mark - 设置子控件
- (void)setupNavi {
    QDCustomNaviBar *naviBar = [QDCustomNaviBar naviBarWithTitle:self.category.title];
    [self.view addSubview:naviBar];
    self.naviBar = naviBar;
}

#pragma mark - 设置 ID
- (void)setCategory:(QDSideBarCategory *)category {
    _category = category;
    // 刷新UI
    self.naviBar.title = category.title;
    [self loadFeeds];
}

- (NSMutableDictionary *)categories {
    if (!_categories) {
        _categories = [NSMutableDictionary dictionary];
    }
    return _categories;
}

#pragma mark - 加载新闻数据
- (void)loadFeeds {
    NSArray *feeds = [self.categories objectForKey:self.category.ID];
    
    // 先清空视图
    [self resetAll];
    
    // 如果字典中没有,表示还没加载过,进入设置 feed 的方法
    if (feeds == nil) {
        [self setupFeeds];
        return;
    }
    
    // 使用之前保存的 feeds 数据,刷新 collectionView
    self.feeds = [NSMutableArray arrayWithArray:feeds];
    // 重新布局
    self.flowLayout.feeds = self.feeds;
    [self.collectionView reloadData];
}

#pragma mark - 加载更多数据
- (void)loadMoreNews {
    // 先从本地缓存找
    [QDFeedCacheTool loadCategoryFeedsCachesWithLastTime:self.last_time filter:@(self.category.ID.integerValue) completed:^(NSArray *feeds) {
        // 如果本地没有就从网络加载
        if (feeds.count == 0) {
            [self loadMoreFeedsFromNetWork];
            return;
        }
        
        // 保存属性上拉加载发送
        self.last_time = @(((QDFeed *)feeds.lastObject).post.publish_time).stringValue;
        self.has_more = YES;

        // 将模型传递给 Layout 对象进行布局设置
        self.flowLayout.feeds = self.feeds;
        
        // 刷新CollectionView
        [self.collectionView reloadData];
        
        if (!self.has_more) { // 表示没有数据了,隐藏 Footer
            self.collectionView.footer.hidden = YES;
        } else {
            // 结束刷新
            [self.collectionView.footer endRefreshing];
        }

    }];
}

/// 对数据进行额外的处理
- (void)handleFeeds:(NSDictionary *)responseObject pullingDown:(BOOL)pullingDown {
    [super handleFeeds:responseObject pullingDown:pullingDown];
    // 保存到字典
    self.categories[self.category.ID] = [self.feeds copy];
    
    // 缓存数据
    [QDFeedCacheTool cacheCategoryFeeds:responseObject];
}
@end
