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
    if (self.params) {
        if ([self.type isEqualToString:@"tag"]) { // 弹出页面使用
            return [NSString stringWithFormat:@"app/tags/index/%@/%@.json?", self.params[@"id"], self.last_time];
        } else {
            return [NSString stringWithFormat:@"app/categories/index/%@/%@.json?", self.params[@"id"], self.last_time];
        }
    } else {
        return [NSString stringWithFormat:@"app/categories/index/%@/%@.json?", self.category.ID, self.last_time];
    }
}

- (NSDictionary *)parameters {
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupNavi];
    
    // push 弹出时使用
    if (self.params) {
        // 创建 category 模型
        QDSideBarCategory *category = [[QDSideBarCategory alloc] init];
        category.title = self.params[@"title"];
        category.ID = self.params[@"id"];
        // category的 setter 方法
        self.category = category;
        
        // 添加按钮
        UIButton *sideBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [sideBarButton setImage:[UIImage imageNamed:@"navigation_back_round_normal"] forState:UIControlStateNormal];
        [sideBarButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        sideBarButton.frame = CGRectMake(15, QDScreenH - 60, 41, 41);
        [self.view addSubview:sideBarButton];
    }
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

#pragma mark - 退出
- (void)cancel {
    [self.navigationController popViewControllerAnimated:YES];
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
    // 取出最后一条新闻
    [QDFeedCacheTool loadCategoryFeedsCachesWithLastTime:self.last_time filter:@(self.category.ID.integerValue) completed:^(NSArray *feeds) {
        // 如果本地没有就从网络加载
        if (feeds.count == 0) {
            [self loadMoreFeedsFromNetWork];
            return;
        }
        
        // 保存属性上拉加载发送
        self.last_time = @(((QDFeed *)feeds.lastObject).post.publish_time).stringValue;
        
        [self.feeds addObjectsFromArray:feeds];

        // 将模型传递给 Layout 对象进行布局设置
        self.flowLayout.feeds = self.feeds;

        // 刷新CollectionView
        [self.collectionView reloadData];
        
         // 结束刷新
        [self.collectionView.mj_footer endRefreshing];

    }];
}

/// 对数据进行额外的处理
- (void)handleFeeds:(NSDictionary *)responseObject pullingDown:(BOOL)pullingDown {
    [super handleFeeds:responseObject pullingDown:pullingDown];
    // 保存到字典
    self.categories[self.category.ID] = [self.feeds copy];
    
    // 缓存数据
    [QDFeedCacheTool cacheCategoryFeeds:responseObject[@"response"] categoryId:self.category.ID.integerValue];
}
@end
