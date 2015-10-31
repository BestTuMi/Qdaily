//
//  QDCategoryFeedViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCategoryFeedViewController.h"
#import "QDCollectionView.h"
#import "QDCustomNaviBar.h"
#import "QDSideBarCategory.h"


#import "QDFeedSmallCell.h"
#import "QDFeedCompactCell.h"
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDFeedLayout.h"
#import <MJRefresh.h>
#import "QDFeedArticleViewController.h"
#import "QDRefreshFooter.h"
#import "QDRefreshHeader.h"
#import "MBProgressHUD+Message.h"

@interface QDCategoryFeedViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
/** 自定义导航条 */
@property (nonatomic, weak)  QDCustomNaviBar *naviBar;
/** collectionView */
@property (nonatomic, weak) QDCollectionView *collectionView;
/** 所有分类 */
@property (nonatomic, strong) NSMutableDictionary *categories;
/** Feeds 保存所有模型数据 */
@property (nonatomic, strong) NSMutableArray *feeds;
/** collectionView 布局 */
@property (nonatomic, strong) QDFeedLayout *flowLayout;
/****** 以下属性上拉加载数据时使用 *******/
/** 是否有更多数据 */
@property (nonatomic,  assign) BOOL has_more;
/** 请求更多数据时传的值 */
@property (nonatomic,  copy) NSString *last_time;

/***** 通知 *******/
@property (nonatomic, weak) NSNotification *note;

@end

static NSString * const smallIdentifier = @"feedSmallCell";
static NSString * const compactIdentifier = @"feedCompactCell";

@implementation QDCategoryFeedViewController

// 消除警告
- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/categories/index/%@/", self.category.ID] ;
}

- (NSDictionary *)parameters {return nil;};

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 初始化布局
    [self setupLayout];
    
    [self setupCollectionView];
    
    // 设置数据源
    [self setupFeeds];
    
    [self setupRefresh];
    
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
    // 刷洗UI
    self.naviBar.title = category.title;
    [self loadFeeds];
}

#pragma mark - lazyload
- (NSMutableArray *)feeds {
    if (!_feeds) {
        _feeds = [NSMutableArray array];
    }
    return _feeds;
}

- (NSMutableDictionary *)categories {
    if (!_categories) {
        _categories = [NSMutableDictionary dictionary];
    }
    return _categories;
}

#pragma mark - 设置刷新组件
- (void)setupRefresh {
    self.collectionView.footer = [QDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreNews)];
    self.collectionView.footer.automaticallyChangeAlpha = YES;
    
    // 添加刷新组件
    self.collectionView.header = [QDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(setupFeeds)];
    self.collectionView.header.automaticallyChangeAlpha = YES;
}

#pragma mark - 加载新闻数据
- (void)loadFeeds {
    NSArray *feeds = [self.categories objectForKey:self.category.ID];
    
    // 先清空视图
    [self.feeds removeAllObjects];
    // 重新布局
    self.flowLayout.feeds = self.feeds;
    // 视图回到顶部
    CGPoint offset = self.collectionView.contentOffset;
    offset.y = - QDNaviBarMaxY;
    self.collectionView.contentOffset = offset;
    [self.collectionView reloadData];
    
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

#pragma mark - setupFeeds(下拉刷新调用)
- (void)setupFeeds {
    
    // 重置lasttime,返回新数据
    self.last_time = @"0";
    
    // 获取新数据
    [[QDFeedTool sharedFeedTool] loadFeedsWithPath:self.requestUrl lasttime:self.last_time finished:^(NSDictionary *responseObject, NSError *error) {
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
        
        // 新闻
        NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
        // 添加到 collectionView 数据源
        [self.feeds addObjectsFromArray:news];
        
        // 保存到字典
        self.categories[self.category.ID] = [self.feeds copy];
        
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

#pragma mark - 加载更多新闻数据
- (void)loadMoreNews {
    
    [[QDFeedTool sharedFeedTool] loadFeedsWithPath:self.requestUrl lasttime:self.last_time finished:^(NSDictionary *responseObject, NSError *error) {
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
        
        // 保存属性上拉加载发送
        self.last_time = [responseObject[@"response"][@"feeds"][@"last_time"] stringValue];
        self.has_more = [responseObject[@"response"][@"feeds"][@"has_more"] boolValue];
        
        // 新闻
        NSArray *news = [QDFeed objectArrayWithKeyValuesArray:responseObject[@"response"][@"feeds"][@"list"]];
        // 添加到 collectionView 数据源
        [self.feeds addObjectsFromArray:news];
        
        // 保存到字典
        self.categories[self.category.ID] = [self.feeds copy];
        
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
    
    if (feed.type == QDFeedCellTypeSmall) {
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
    QDFeedArticleViewController *feedArticleVc = [[QDFeedArticleViewController alloc] init];
    feedArticleVc.feed = self.feeds[indexPath.item];
    [self.navigationController pushViewController:feedArticleVc animated:YES];
}

@end
