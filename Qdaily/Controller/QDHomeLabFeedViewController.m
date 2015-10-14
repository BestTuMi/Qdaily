//
//  QDLabTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeLabFeedViewController.h"
#import <AFNetworking.h>
#import "QDFeedPaperCell.h"
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDFeedLayout.h"
#import <MJRefresh.h>

@interface QDHomeLabFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;
/** AFN 管理者 */
@property (nonatomic, strong)  AFHTTPSessionManager *manager;
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

@implementation QDHomeLabFeedViewController

static NSString * const paperIdentifier = @"feedPaperCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
    self.collectionView.footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreNews)];
    self.collectionView.footer.automaticallyChangeAlpha = YES;
}

#pragma mark - setupFeeds
- (void)setupFeeds {
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    [self.manager GET:@"app/papers/index/0.json?" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        QDLogVerbose(@"%@", responseObject);
        
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
        
        if (!self.has_more) { // 表示没有数据了,隐藏 Footer
            self.collectionView.footer.hidden = YES;
        } else {
            // 结束刷新
            [self.collectionView.footer endRefreshing];
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark - 加载更多新闻数据
- (void)loadMoreNews {
    
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    NSString *urlString = [NSString stringWithFormat:@"app/papers/index/%@.json?", self.last_time];
    
    [self.manager GET:urlString parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        QDLogVerbose(@"%@", responseObject);
        
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
        }
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        // 结束刷新
        [self.collectionView.footer endRefreshing];
    }];
}

- (void)setupLayout {
    QDFeedLayout *flowLayout = [[QDFeedLayout alloc] init];
    self.flowLayout = flowLayout;
}

- (void)setupCollectionView {
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    
    // 设置数据源和代理
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    // 添加 collectionView
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册Cell
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
    QDFeed *feed = nil;
    feed = self.feeds[indexPath.item];

    QDFeedPaperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:paperIdentifier forIndexPath:indexPath];
    cell.feed = feed;
    return cell;
}

@end
