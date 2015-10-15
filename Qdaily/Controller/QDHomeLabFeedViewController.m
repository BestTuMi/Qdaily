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
    // KVO 监听 contentOffset 的改变
    [self.collectionView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    NSNotification *note = [NSNotification notificationWithName:QDFeedCollectionViewOffsetChangedNotification object:self userInfo:change];
    [[NSNotificationCenter defaultCenter] postNotification:note];
}

- (void)updateContentOffset: (NSNotification *)note {
    if (note.object == self) { // 不接受自己发出的通知
        return;
    } else {
        // 另一个控制器的当前 offset
        CGPoint offset = [note.userInfo[NSKeyValueChangeNewKey] CGPointValue];
        CGPoint selfOffset = self.collectionView.contentOffset;
        if (offset.y >= 0) { // NaviBar 已经隐藏
            if (selfOffset.y <= - QDNaviBarMaxY) {
                // 如果collectionView 的 offset 小于 -64,那么顶部将显示一片空白
                // 上滚
                selfOffset.y = 0;
                self.collectionView.contentOffset = selfOffset;
            }
        }
    }
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

#pragma mark - 处理松手时的状况
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectionView.contentOffset;
    CGFloat offsetY = offset.y;
    if ( offsetY >= - QDNaviBarMaxY * 0.5 && offsetY <= 0) { // 顶部上一半
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint offset = self.collectionView.contentOffset;
            offset.y = 0;
            self.collectionView.contentOffset = offset;
        }];
    } else if ( offsetY > - QDNaviBarMaxY && offsetY < - QDNaviBarMaxY + QDNaviBarMaxY * 0.5) { // 顶部下一半
        [UIView animateWithDuration:0.25 animations:^{
            CGPoint offset = self.collectionView.contentOffset;
            offset.y = - QDNaviBarMaxY;
            self.collectionView.contentOffset = offset;
        }];
    }
}

@end
