//
//  QDNotificationMyLabViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNotificationMyLabViewController.h"
#import <AFNetworking.h>
#import "QDFeedCompactCell.h"
#import "QDFeedPaperCell.h"
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDFeedLayout.h"
#import <MJRefresh.h>
#import "QDFeedArticleViewController.h"
#import "QDRefreshFooter.h"
#import "QDCollectionView.h"
#import "QDRefreshHeader.h"

@interface QDNotificationMyLabViewController ()  <UICollectionViewDataSource, UICollectionViewDelegate>

/** collectionView */
@property (nonatomic, weak) QDCollectionView *collectionView;
/** AFN 管理者 */
@property (nonatomic, strong) AFHTTPSessionManager *manager;
/** Feeds 保存所有模型数据 */
@property (nonatomic, strong) NSMutableArray *feeds;
/** collectionView 布局 */
@property (nonatomic, strong) QDFeedLayout *flowLayout;
/****** 以下属性上拉加载数据时使用 *******/
/** 是否有更多数据 */
@property (nonatomic,  assign) BOOL has_more;
/** 请求更多数据时传的值 */
@property (nonatomic,  copy) NSString *last_time;

@end

@implementation QDNotificationMyLabViewController

static NSString * const compactIdentifier = @"feedCompactCell";
static NSString * const paperIdentifier = @"feedPaperCell";

// 消除警告
- (NSString *)requestUrl {return @"app/users/papers";}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 添加对其他collectionView contentOffset 改变的通知
    // 更新自己的 contentOffset, 以免导航栏因为其他控制器消失,而导致当前控制器导航栏出空白
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateContentOffset:) name:QDFeedCollectionViewOffsetChangedNotification object:nil];
    
    // 设置数据源
    [self setupFeeds];
    
    // 初始化布局
    [self setupLayout];
    
    [self setupCollectionView];
    
    [self setupRefresh];
    
}

#pragma mark - lazyload
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:QDBaseURL];
    }
    return _manager;
}

- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [NSMutableArray array];
    }
    return _feeds;
}

#pragma mark - 设置刷新组件
- (void)setupRefresh {
    self.collectionView.footer = [QDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreNews)];
    self.collectionView.footer.automaticallyChangeAlpha = YES;
    
    // 添加刷新组件
    self.collectionView.header = [QDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(setupFeeds)];
    self.collectionView.header.automaticallyChangeAlpha = YES;
}

#pragma mark - setupFeeds
- (void)setupFeeds {
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 重置lasttime,返回新数据
    self.last_time = nil;
    
    NSDictionary *params = @{@"lastime" : self.last_time == nil ? @(0) : self.last_time};
    
    [self.manager GET:self.requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        QDLogVerbose(@"%@", responseObject);
        
        // 移除模型数组所有元素
        [self.feeds removeAllObjects];
        
        // 保存属性上拉加载发送
        self.last_time = responseObject[@"response"][@"feeds"][@"last_time"];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 新闻
        NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
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
        if (error) {
            QDLogVerbose(@"%@", error);
        }
        [self.collectionView.header endRefreshing];
    }];
}

#pragma mark - 加载更多新闻数据
- (void)loadMoreNews {
    
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSDictionary *params = @{@"lastime" : self.last_time == nil ? 0 : self.last_time};
    [self.manager GET:self.requestUrl parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 保存属性上拉加载发送
        self.last_time = [responseObject[@"response"][@"feeds"][@"last_time"] stringValue];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 新闻
        NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
        // 添加到 collectionView 数据源
        [self.feeds addObjectsFromArray:news];
        
        // 将模型传递给 Layout 对象进行布局设置
        self.flowLayout.feeds = self.feeds;
        
        // 刷新CollectionView
        [self.collectionView reloadData];
        
        if (!self.has_more) { // 表示没有数据了,隐藏 Footer
            self.collectionView.footer.hidden = YES;
        } else {
            // 结束刷新
            [self.collectionView.footer endRefreshing];
            [self.collectionView.header endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 结束刷新
        [self.collectionView.footer endRefreshing];
        [self.collectionView.header endRefreshing];
    }];
}

- (void)setupLayout {
    QDFeedLayout *flowLayout = [[QDFeedLayout alloc] init];
    self.flowLayout = flowLayout;
}

- (void)setupCollectionView {
    
    QDCollectionView *collectionView = [[QDCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    
    // 设置数据源和代理
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    // 添加 collectionView
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册Cell
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedCompactCell class]) bundle:nil] forCellWithReuseIdentifier:compactIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedPaperCell class]) bundle:nil] forCellWithReuseIdentifier:paperIdentifier];
    
    // 设置内边距
    self.collectionView.contentInset = UIEdgeInsetsMake(QDNaviBarMaxY, 0, 0, 0);
    self.collectionView.backgroundColor = QDLightGrayColor;
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.feeds.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    // 获取模型
    QDFeed *feed = self.feeds[indexPath.item];
    
    if (feed.post.genre == QDGenrePaper || feed.post.genre == QDGenreReport || feed.post.genre == QDGenreVote) {
        QDFeedPaperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:paperIdentifier forIndexPath:indexPath];
        cell.feed = feed;
        return cell;
    } else { // QDFeedCellTypeCompact
        QDFeedCompactCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:compactIdentifier forIndexPath:indexPath];
        cell.feed = feed;
        return cell;
    }
    
}

#pragma mark - 处理松手时的状况
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

#pragma mark - collectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QDFeedArticleViewController *feedArticleVc = [[QDFeedArticleViewController alloc] init];
    feedArticleVc.feed = self.feeds[indexPath.item];
    [self.navigationController pushViewController:feedArticleVc animated:YES];
}

@end
