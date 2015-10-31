//
//  QDCarouselView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/13.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCarouselView.h"
#import "QDFeed.h"
#import "QDPost.h"
#import "QDCategory.h"
#import "Masonry.h"
#import "QDFeedCompactCell.h"
#import "QDFeedArticleViewController.h"
#import "QDNavigationController.h"

//define this constant if you want to enable auto-boxing for default syntax
#define MAS_SHORTHAND_GLOBALS

/** 定时器更新的时间间隔 */
static NSInteger const timeInterval = 5;

@interface QDCarouselView () <UICollectionViewDelegate, UICollectionViewDataSource>
/** collectionView */
@property (nonatomic, weak) UICollectionView *mainView;
/** layout 对象 */
@property (nonatomic, strong)  UICollectionViewFlowLayout *flowLayout;
/** PageControl */
@property (nonatomic, weak) UIPageControl *pageControl;
/** 定时器 */
@property (nonatomic, weak)  NSTimer *timer;
/** 图片总数 */
@property (nonatomic, assign)  NSInteger totalItemsCount;

@end


@implementation QDCarouselView

static NSString *const identifier = @"feedCompactCell";

- (void)awakeFromNib {
    
    // 创建 ScrollView
    [self setupMainView];
    
    [self setupPageControl];
}

#pragma mark - lazyload

#pragma mark - 设置 ScrollView
- (void)setupMainView {
    // layout 对象
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout = flowLayout;
    
    UICollectionView *mainView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    mainView.showsHorizontalScrollIndicator = NO;
    mainView.showsVerticalScrollIndicator = NO;
    mainView.pagingEnabled = YES;
    [self addSubview:mainView];
    
    self.mainView = mainView;
    
    // 设置代理和数据源
    self.mainView.delegate = self;
    self.mainView.dataSource = self;
    
    // 注册 Cell
    [self.mainView registerNib:[UINib nibWithNibName:NSStringFromClass([QDFeedCompactCell class]) bundle:nil] forCellWithReuseIdentifier:identifier];
    
    // 设置约束
    [mainView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

#pragma mark - 分页控制
- (void)setupPageControl {
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    
    pageControl.numberOfPages = 5;
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = QDHighlightColor;
    
    [self addSubview:pageControl];
    self.pageControl = pageControl;
    
    // 设置约束
    // 设置分页控制
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(self.mainView.mas_width);
        make.height.equalTo(@30);
        make.bottom.equalTo(self.mainView.mas_bottom);
    }];
}

#pragma mark - 设置模型
- (void)setBanners:(NSArray *)banners {
    _banners = banners;
    
    _totalItemsCount = banners.count * 100;
    
    // 开始滚动
    [self startTimer];
}

#pragma mark - 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    // 设置 item 的尺寸
    self.flowLayout.itemSize = self.bounds.size;
    self.flowLayout.minimumLineSpacing = 0;
    
    // 设置Cell初始位置
    int targetIndex = 0;
    if (self.mainView.contentOffset.x == 0) {
        // 从中间开始滚动
        targetIndex = _totalItemsCount * 0.5;
        self.pageControl.currentPage = 0;
    }
    [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:kNilOptions animated:NO];
}

#pragma mark -
#pragma mark - 自动滚动相关
- (void)startScroll {
    // 获取当前 cell 所在 index
    int currentIndex = 0;
    int targetIndex = 0;
    currentIndex = self.mainView.contentOffset.x / self.mainView.width;
    targetIndex = currentIndex + 1;
    
    if (targetIndex < _totalItemsCount) {
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:targetIndex inSection:0] atScrollPosition:kNilOptions animated:YES];
    } else {
        [self.mainView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:1 inSection:0] atScrollPosition:kNilOptions animated:NO];
    }
}

- (void)startTimer {
    // 先停掉上一个定时器
    [self stopTimer];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(startScroll) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    _timer = timer;
}

- (void)stopTimer {
    [self.timer invalidate];;
    self.timer = nil;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // 创建足够多的 item 来进行循环展示
    return _totalItemsCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    QDFeedCompactCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    // 取出模型(取余,循环展示)
    QDFeed *feed = self.banners[indexPath.item % self.banners.count];

    // 设置模型
    cell.feed = feed;
    return cell;
}

#pragma mark - collectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    QDFeedArticleViewController *feedArticleVc = [[QDFeedArticleViewController alloc] init];
    feedArticleVc.feed = self.banners[indexPath.item % _banners.count];
    [(QDNavigationController *)self.window.rootViewController pushViewController:feedArticleVc animated:YES];
}

#pragma mark - scrollView delegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    // 停止定时器
    [self stopTimer];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    int currentIndex = 0;
    currentIndex = (int)self.mainView.contentOffset.x / self.mainView.width;
    self.pageControl.currentPage = currentIndex % (self.banners.count);
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (decelerate == NO) {
        [self scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self stopTimer];
    [self startTimer];
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

@end
