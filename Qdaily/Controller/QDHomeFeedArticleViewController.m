//
//  QDQTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeFeedArticleViewController.h"
#import <AFNetworking.h>
#import "QDFeedBannerCell.h"
#import "QDFeedSmallCell.h"
#import "QDFeedCompactCell.h"

@interface QDHomeFeedArticleViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;
/** AFN 管理者 */
@property (nonatomic, strong)  AFHTTPSessionManager *manager;
/** Feeds 保存所有模型数据 */
@property (nonatomic, strong) NSMutableArray *feeds;
/** Banner 模型数组 */
@property (nonatomic, copy) NSArray *banners;
/** 所有文章模型数组 */
@property (nonatomic, strong)  NSMutableArray *articles;
@end

@implementation QDHomeFeedArticleViewController

static NSString * const bannerIdentifier = @"feedBannerCell";
static NSString * const smallIdentifier = @"feedSmallCell";
static NSString * const compactIdentifier = @"feedCompactCell";


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置数据源
    [self setupFeeds];
    
    [self setupCollectionView];
}

#pragma mark - lazyload
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:QDBaseURL];
    }
    return _manager;
}

#pragma mark - setupFeeds
- (void)setupFeeds {
    [self.manager GET:@"app/homes/index/0.json?" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {

    }];
}

- (void)setupCollectionView {
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    
    // 设置数据源和代理
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    // 添加 collectionView
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    
    // 注册
    [self.collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedSmallCell class]) bundle:nil] forCellWithReuseIdentifier:smallIdentifier];
    
    // 设置内边距
    self.collectionView.contentInset = UIEdgeInsetsMake(QDNaviBarMaxY, 0, 0, 0);
    self.collectionView.backgroundColor = QDRandomColor;
}

#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(QDScreenW * 0.4, 50);
    
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QDFeedSmallCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:smallIdentifier forIndexPath:indexPath];

    cell.titleLabel.text = @"标题";
    cell.backgroundColor = QDRandomColor;
    return cell;
}
@end
