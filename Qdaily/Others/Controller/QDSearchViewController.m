//
//  QDSearchViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/19.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSearchViewController.h"
#import "objc/runtime.h"
#import <AFNetworking.h>
#import "QDRefreshFooter.h"
#import "QDSearchResultCell.h"
#import "QDResult.h"
#import <MJExtension.h>
#import "Masonry.h"
#import "QDFeedArticleViewController.h"
#import "QDNavigationController.h"
#import "QDCustomNaviBar.h"

@interface QDSearchViewController () <UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate>
/** 自定义的 tableview */
@property (nonatomic, weak) UITableView *tableView;
/** 自定义导航条 */
@property (nonatomic, weak)  UIView *naviBar;
/** 搜索输入框 */
@property (nonatomic, weak) UISearchBar *searchBar;
/** AFN 管理者 */
@property (nonatomic, strong)  AFHTTPSessionManager *manager;
/**  搜索结果模型数组 */
@property (nonatomic, strong)  NSMutableArray *results;
/** 搜索结果总数 */
@property (nonatomic, assign)  NSInteger totalNumber;

/** 搜索关键词 */
@property (nonatomic, copy)  NSString *keyWord;

/****** 以下属性上拉加载数据时使用 *******/
/** 是否有更多数据 */
@property (nonatomic,  assign) BOOL has_more;
/** 请求更多数据时传的值 */
@property (nonatomic,  copy) NSString *last_time;

@end

@implementation QDSearchViewController

/**
//+ (void)load {
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UISearchBar class], &count);
//    for (int i = 0; i < count; i++) {
//        QDLogVerbose(@"%s", ivar_getName(ivars[i]));
//    }
//}
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupTableView];
    
    [self setupNavi];
    
    [self setupRefresh];
}

#pragma mark - lazyload
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [AFHTTPSessionManager manager];
    }
    return _manager;
}

- (NSMutableArray *)results {
    if (!_results) {
        _results = [NSMutableArray array];
    }
    return _results;
}

#pragma mark - 设置表格
- (void)setupTableView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
    self.tableView = tableView;
    
    self.tableView.contentInset = UIEdgeInsetsMake(QDNaviBarMaxY, 0, 0, 0);
    self.tableView.rowHeight = 110;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

#pragma mark - 设置导航栏
- (void)setupNavi {
    self.navigationController.navigationBarHidden = YES;
    
    QDCustomNaviBar *naviBar = [QDCustomNaviBar naviBarWithTitle:nil];
    
    naviBar.frame = CGRectMake(0, - QDNaviBarMaxY, QDScreenW, QDNaviBarMaxY);
    
    [self.view addSubview:naviBar];
    
    self.naviBar = naviBar;
    
    [self setupSearchBar];
}

#pragma mark - 设置刷新组件
- (void)setupRefresh {
    self.tableView.footer = [QDRefreshFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreResults)];
}

#pragma mark - 加载搜索结果
- (void)loadResults {
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 对搜索关键词百分号转义
    NSString *searchStr = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchUrl = [NSString stringWithFormat:@"http://app.qdaily.com/app/searches/post_list?last_time=0&search=%@", searchStr];

    QDWeakSelf;
    [self.manager GET:searchUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        // 移除所有模型
        [weakSelf.results removeAllObjects];
        
        // 获取页面加载相关信息
        weakSelf.last_time = responseObject[@"response"][@"searches"][@"last_time"];
        weakSelf.has_more = [responseObject[@"response"][@"searches"][@"has_more"] boolValue];
        weakSelf.totalNumber = [responseObject[@"response"][@"total_number"] integerValue];
        
        [weakSelf setupHeaderView];
        weakSelf.tableView.tableHeaderView.hidden = NO;
        
        NSArray *results = [QDResult objectArrayWithKeyValuesArray:responseObject[@"response"][@"searches"][@"list"]];
        
        [weakSelf.results addObjectsFromArray:results];
        
        // 刷新表格
        [weakSelf.tableView reloadData];
        
        if (weakSelf.results.count >= weakSelf.totalNumber) {
            weakSelf.tableView.footer.hidden = YES;
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark - 加载更多搜索结果
- (void)loadMoreResults {
    // 取消之前的请求
    [self.manager.tasks makeObjectsPerformSelector:@selector(cancel)];
    
    // 对搜索关键词百分号转义
    NSString *searchStr = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *searchUrl = [NSString stringWithFormat:@"http://app.qdaily.com/app/searches/post_list?last_time=%@&search=%@", self.last_time, searchStr];
    
    QDWeakSelf;
    [self.manager GET:searchUrl parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // 获取页面加载相关信息
        weakSelf.last_time = responseObject[@"response"][@"searches"][@"last_time"];
        weakSelf.has_more = [responseObject[@"response"][@"searches"][@"has_more"] boolValue];
        
        NSArray *results = [QDResult objectArrayWithKeyValuesArray:responseObject[@"response"][@"searches"][@"list"]];
        
        [weakSelf.results addObjectsFromArray:results];
        
        // 刷新表格
        [weakSelf.tableView reloadData];
        
        // (服务器数据有可能会被删除,所以判断大于等于),减1是因为第一个模型是总数
        if (weakSelf.results.count >=  weakSelf.totalNumber) { // 超出总数,没有更多了
            weakSelf.tableView.footer.hidden = YES;
        } else {
            // 停止刷新
            [weakSelf.tableView.footer endRefreshing];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [weakSelf.tableView.footer endRefreshing];
    }];
}

- (void)setupHeaderView {
    // 会被系统调整为tableview 宽度
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 44)];
    headerView.backgroundColor = QDRGBWhiteColor(1.0, 1.0);
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:16.0];
    
    [headerView addSubview:titleLabel];
    
    // 设置约束
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@10);
        make.centerY.equalTo(headerView.mas_centerY);
    }];
    titleLabel.text = @"文章";
    
    UILabel *countLabel = [[UILabel alloc] init];
    countLabel.font = [UIFont systemFontOfSize:12];
    
    [headerView addSubview:countLabel];
    
    // 设置约束
    [countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLabel.mas_right).offset(10);
        make.bottom.equalTo(titleLabel.mas_bottom);
    }];
    countLabel.text = [NSString stringWithFormat:@"(%zd条搜索结果)", self.totalNumber];
    
    // 分割线
    UIView *seprator = [[UIView alloc] init];
    seprator.alpha = 0.25;
    seprator.backgroundColor = [UIColor lightGrayColor];
    [headerView addSubview:seprator];
    
    [seprator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(headerView).offset(10);
        make.right.equalTo(headerView).offset(-10);
        make.bottom.equalTo(headerView).offset(-0.5);
        make.height.equalTo(@(0.5f));
    }];
    
    self.tableView.tableHeaderView = headerView;
}

// 设置输入框
- (void)setupSearchBar {
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.frame = CGRectMake(15, 25, 300, 28);
    searchBar.tintColor = QDHighlightColor;
    searchBar.backgroundImage = [[UIImage alloc] init];
    searchBar.placeholder = @" 搜索";
    searchBar.showsCancelButton = YES;
    
    [self.naviBar addSubview:searchBar];
    
    self.searchBar = searchBar;
    
    // 设置代理
    self.searchBar.delegate = self;
    
    [_searchBar becomeFirstResponder];
}

#pragma mark - UISearchBar Delegate
/*!
 *  @brief  点击了搜索框的取消按钮
 *
 *  @param searchBar 搜索框
 */
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar endEditing:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*!
 *  @brief  搜索按钮点击后调用
 *
 *  @param searchBar 搜索工具条
 */
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // 记录搜索关键词
    if (self.searchBar.text.length == 0) {
        return;
    }
    self.keyWord = self.searchBar.text;
    
    // 点击搜索后的事件
    [self loadResults];
    
    // 收起键盘
    [self.searchBar endEditing:YES];
}

#pragma mark - scrollView Delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar endEditing:YES];
}

#pragma mark - tableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.results.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    QDSearchResultCell *cell = [QDSearchResultCell cellWithTableView: tableView];
    // 取模型
    QDResult *result = self.results[indexPath.row];
    cell.result = result;
    return cell;
}

#pragma mark - tableView delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    QDFeedArticleViewController *feedArticleVc = [[QDFeedArticleViewController alloc] init];
    QDFeed *feed = self.results[indexPath.row];
    feedArticleVc.feed = feed;
    [self.navigationController pushViewController:feedArticleVc animated:YES];
}

@end
