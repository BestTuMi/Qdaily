//
//  QDCommentOnMyViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCommentOnMyViewController.h"
#import "QDRefreshHeader.h"
#import "QDCollectionView.h"
#import "QDEmptyInfoView.h"
#import "Masonry.h"
#import "QDNotificationHeaderCell.h"

@interface QDCommentOnMyViewController () <UITableViewDataSource, UITableViewDelegate>
/** collectionView */
@property (nonatomic, weak) UITableView *tableView;
/** collectionView自定义背景视图 */
@property (nonatomic, weak)  UIView *backgroungView;
@end

@implementation QDCommentOnMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self setupTableView];
    
    [self setupRefresh];
}

- (void)setupTableView {
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.backgroundColor = QDLightGrayColor;
    
    tableView.contentInset = UIEdgeInsetsMake(QDNaviBarMaxY + QDToolBarH, 0, 0, 0);
     self.tableView = tableView;
    
    // 设置背景视图
    [self setupBackgroudView];
    
    // 去掉多余分割线
    tableView.tableFooterView = [[UIView alloc] init];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    
    // 设置代理和数据源
    tableView.dataSource = self;
    tableView.delegate = self;
    
    [self.view addSubview:tableView];
   
}

- (void)setupBackgroudView {
    // 背景视图,显示一些提示信息
    QDEmptyInfoView *emptyInfoView = [[QDEmptyInfoView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.width,  self.tableView.height)];
    [self.tableView insertSubview:emptyInfoView atIndex:0];
}

- (void)viewDidLayoutSubviews {
    // 放到背景层后面
    [self.tableView insertSubview:self.tableView.mj_header atIndex:0];
}

- (void)setupRefresh {
    self.tableView.mj_header = [QDRefreshHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadComments)];
}

- (void)loadComments {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 如果有被评论的数据...就隐藏自定义的背景
        [self.tableView.mj_header endRefreshing];
    });
}

#pragma mark - tableView dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *const commentCell = @"commentCell";
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:commentCell];
    
    if (indexPath.item == 0) { // 作为 header
        QDNotificationHeaderCell *cell = [QDNotificationHeaderCell cellWithTableView:tableView];
        return cell;
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commentCell];
        cell.backgroundColor = QDRandomColor;
        return cell;
    }
    
}

@end
