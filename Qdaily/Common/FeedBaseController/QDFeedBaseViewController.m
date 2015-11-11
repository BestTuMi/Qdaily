//
//  QDFeedBaseViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/11/5.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedBaseViewController.h"

#import "QDCollectionView.h"
#import "QDFeedBannerCell.h"
#import "QDFeedSmallCell.h"
#import "QDFeedCompactCell.h"
#import "QDFeedPaperCell.h"
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDFeedLayout.h"
#import <MJRefresh.h>
#import "QDFeedArticleViewController.h"
#import "QDRefreshFooter.h"
#import "QDRefreshHeader.h"
#import "MBProgressHUD+Message.h"
#import "QDFeedCacheTool.h"


@interface QDFeedBaseViewController ()

@end

@implementation QDFeedBaseViewController

- (NSString *)requestUrl {
    return @"/app/users/praises";
}

- (NSDictionary *)parameters {return nil;}

static NSString * const bannerIdentifier = @"feedBannerCell";
static NSString * const smallIdentifier = @"feedSmallCell";
static NSString * const compactIdentifier = @"feedCompactCell";
static NSString * const paperIdentifier = @"feedPaperCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化布局
    [self setupLayout];
    
    [self setupCollectionView];
    
    // 设置数据源
    [self setupFeeds];
    
    [self setupRefresh];
    
}

#pragma mark - lazyload
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

/*!
 *  @brief  重置视图,清空数据,包括滚动位置
 */
- (void)resetAll {
    // 先清空视图
    [self.feeds removeAllObjects];
    // 重新布局
    self.flowLayout.feeds = self.feeds;
    // 视图回到顶部
    CGPoint offset = self.collectionView.contentOffset;
    offset.y = - QDNaviBarMaxY;
    self.collectionView.contentOffset = offset;
    [self.collectionView reloadData];
}

#pragma mark - setupFeeds(下拉刷新调用)
- (void)setupFeeds {

    // 重置lasttime,返回新数据
    self.last_time = @"0";

    [[QDFeedTool sharedFeedTool] loadFeedsWithPath:self.requestUrl parameters:self.parameters finished:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (responseObject == nil) {
            // 停止下拉刷新
            [self.collectionView.header endRefreshing];
            return;
        }
        
        // 网络是否错误
        if (error) {
            QDLogVerbose(@"%@", error);
            // 停止下拉刷新
            [self.collectionView.header endRefreshing];
            return;
        }
        
        // 移除模型数组所有元素
        [self.feeds removeAllObjects];
        
        // 保存属性上拉加载发送
        self.last_time = responseObject[@"response"][@"feeds"][@"last_time"];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 处理模型数据
        [self handleFeeds:responseObject pullingDown:YES];
        
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
    }];
}

#pragma mark - 处理模型数据
- (void)handleFeeds: (NSDictionary *)responseObject pullingDown: (BOOL)pullingDown {
    // 新闻
    NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
    
    // 添加到 collectionView 数据源
    [self.feeds addObjectsFromArray:news];
}

#pragma mark - 加载更多新闻数据
- (void)loadMoreNews {
    [self loadMoreFeedsFromNetWork];
}

#pragma mark - 从网络加载更多数据
- (void)loadMoreFeedsFromNetWork {
    [[QDFeedTool sharedFeedTool] loadFeedsWithPath:self.requestUrl parameters:self.parameters finished:^(NSDictionary *responseObject, NSError *error)  {
        // 验证数据
        if (responseObject == nil) {
            [MBProgressHUD showError:error.userInfo[@"msg"]];
            // 停止上拉加载
            [self.collectionView.footer endRefreshing];
            return;
        }
        
        // 网络是否错误
        if (error) {
            QDLogVerbose(@"%@", error);
            // 停止上拉加载
            [self.collectionView.header endRefreshing];
            return;
        }
        QDLogVerbose(@"数据来自网络");
        // 保存属性上拉加载发送
        self.last_time = [responseObject[@"response"][@"feeds"][@"last_time"] stringValue];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 处理数据
        [self handleFeeds:responseObject pullingDown:NO];
        
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

- (void)setupLayout {
    QDFeedLayout *flowLayout = [[QDFeedLayout alloc] init];
    self.flowLayout = flowLayout;
}

#pragma mark - 设置 collectionView
- (void)setupCollectionView {
    
    QDCollectionView *collectionView = [[QDCollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
    
    // 设置数据源和代理
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    // 添加 collectionView
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册Cell
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedSmallCell class]) bundle:nil] forCellWithReuseIdentifier:smallIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedCompactCell class]) bundle:nil] forCellWithReuseIdentifier:compactIdentifier];
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedBannerCell class]) bundle:nil] forCellWithReuseIdentifier:bannerIdentifier];
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
    
    if (indexPath.item == 0 && [feed isKindOfClass:[NSArray class]]) { // 轮播图
        QDFeedBannerCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:bannerIdentifier forIndexPath:indexPath];
        cell.banners = (NSArray *)feed;
        return cell;
    } else if (feed.post.genre == QDGenrePaper || feed.post.genre == QDGenreReport || feed.post.genre == QDGenreVote) { // 好奇心实验室
        // 注意:报告的类型是小图,所以要先判断
        QDFeedPaperCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:paperIdentifier forIndexPath:indexPath];
        feed.post.isNew = (indexPath.item == 0 || indexPath.item == 1) ? YES : NO;
        cell.feed = feed;
        return cell;
    } else if (feed.type == QDFeedCellTypeSmall) {
        QDFeedSmallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:smallIdentifier forIndexPath:indexPath];
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

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 处理菜单按钮的定时器
    [[NSNotificationCenter defaultCenter] postNotificationName:QDCollectionViewDidEndScrollNotification object:nil userInfo:nil];
}

#pragma mark - collectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    // 取出模型
    QDFeed *feed = self.feeds[indexPath.item];
    if (feed.post.genre == QDGenreVote || feed.post.genre == QDGenrePaper) { // 不通过网页加载
        QDLogVerbose(@"%@", feed.post.ID);
    } else {
        QDFeedArticleViewController *feedArticleVc = [[QDFeedArticleViewController alloc] init];
        feedArticleVc.feed = self.feeds[indexPath.item];
        [self.navigationController pushViewController:feedArticleVc animated:YES];
    }
}

@end
