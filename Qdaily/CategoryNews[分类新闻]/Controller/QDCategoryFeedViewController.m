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

/// 对数据进行额外的处理
- (void)handleFeeds:(NSDictionary *)responseObject pullingDown:(BOOL)pullingDown {
    [super handleFeeds:responseObject pullingDown:pullingDown];
    // 保存到字典
    self.categories[self.category.ID] = [self.feeds copy];
}
@end
