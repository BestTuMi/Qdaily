//
//  QDNewFeaturesViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/22.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNewFeaturesViewController.h"
#import "QDNewFeaturesFlowLayout.h"
#import "QDNewFeaturesCell.h"
#import "Masonry.h"

@interface QDNewFeaturesViewController ()
/** 分页控制 */
@property (nonatomic, weak) UIPageControl *pageControl;

@end

@implementation QDNewFeaturesViewController

static NSString * const reuseIdentifier = @"Cell";
static int const pages = 4;

+ (instancetype)featuresVc {
    // 对布局其他属性进行配置
    QDNewFeaturesFlowLayout *flowLayout = [[QDNewFeaturesFlowLayout alloc] init];
    return [[self alloc] initWithCollectionViewLayout:flowLayout];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Register cell classes
    [self.collectionView registerClass:[QDNewFeaturesCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    // 设置分页控制
    [self setupPageControl];
}

- (void)setupPageControl {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    pageControl.numberOfPages = 4;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = QDHighlightColor;
    
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
    
    // 设置约束
    // 设置分页控制
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(@80);
        make.bottom.equalTo(self.view.mas_bottom);
    }];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return pages;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QDNewFeaturesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];

    cell.imageView.image = [UIImage imageNamed: [NSString stringWithFormat:@"new_features_%zd", indexPath.item + 1]];
    
    if (indexPath.item == pages - 1) { // 最后一页
        cell.startButton.hidden = NO;
    } else {
        cell.startButton.hidden = YES;
    }

    return cell;
}


#pragma mark <UICollectionViewDelegate>
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == pages - 1) {
        // 发送被点击的通知,切换根控制器
        [[NSNotificationCenter defaultCenter] postNotificationName:QDChangeRootVCNotification object:self userInfo:nil];
    }
}

#pragma mark - scrollView delegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 获取当前页面索引号
    NSInteger index = scrollView.contentOffset.x / QDScreenW;
    // 设置 page
    self.pageControl.currentPage = index;
}

@end


