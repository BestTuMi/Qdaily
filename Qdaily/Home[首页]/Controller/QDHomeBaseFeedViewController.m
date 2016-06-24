//
//  QDBaseFeedViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeBaseFeedViewController.h"
#import "QDFeed.h"
#import <MJExtension.h>
#import "QDCollectionView.h"

@interface QDHomeBaseFeedViewController ()


@end

@implementation QDHomeBaseFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
   
    // 初始化时是否需要上滚
    self.collectionView.shouldScrollToTop = self.naviBarHidden;
    
    // 添加蒙版层
    [self setupMaskView];
    
    // 判断当前导航栏状态,如果为隐藏, 将要显示的 collectionView 需要上滚
    // 否则会出现顶部空白
    @weakify(self);
    [[[[[[[[NSNotificationCenter defaultCenter] rac_addObserverForName:QDFeedCollectionViewOffsetChangedNotification object:nil]
          takeUntil:[self rac_willDeallocSignal]]
         filter:^BOOL(NSNotification *note) {
             // 不接受自己发出的通知
            return note.object != self;
         }]
        map:^id(id value) {
            return @([[value userInfo][NSKeyValueChangeNewKey] CGPointValue].y);
        }] filter:^BOOL(id value) {
            // NaviBar 已经隐藏
            return [value doubleValue] >= 0;
        }]
      deliverOnMainThread]
     subscribeNext:^(id x) {
        @strongify(self);
        // 另一个控制器的当前 offset
        CGPoint selfOffset = self.collectionView.contentOffset;
        if (selfOffset.y <= - QDNaviBarMaxY) {
            // 如果collectionView 的 offset 小于 -64,那么顶部将显示一片空白
            // 上滚
            selfOffset.y = 0;
            self.collectionView.contentOffset = selfOffset;
        }
    }];
    
    // KVO 监听 contentOffset 的改变
    [[self.collectionView rac_valuesAndChangesForKeyPath:NSStringFromSelector(@selector(contentOffset)) options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld observer:self]
     subscribeNext:^(RACTuple *x) {
        @strongify(self);
        NSDictionary *change = x.second;
        NSNotification *note = [NSNotification notificationWithName:QDFeedCollectionViewOffsetChangedNotification object:self userInfo:change];
        [[NSNotificationCenter defaultCenter] postNotification:note];
    }];

}

#pragma mark - 添加蒙版层
- (void)setupMaskView {
    UIView *maskView = [[UIView alloc] initWithFrame:self.view.bounds];
    maskView.backgroundColor = QDRGBWhiteColor(0, 1.0);
    maskView.alpha = 0;
    [self.view addSubview:maskView];
    self.maskView = maskView;
}

- (void)handleFeeds:(NSDictionary *)responseObject pullingDown:(BOOL)pullingDown {
    // 下拉需要处理轮播图
    if (pullingDown) {
        // 轮播图
        NSArray *banners = [NSArray array];
        banners = [QDFeed mj_objectArrayWithKeyValuesArray:responseObject[@"response"][@"banners"][@"list"]];
        
        // 将轮播图以数组形式添加到 collectionView 数据源,目的是方便计算布局
        // 注意:子类可能没有轮播图
        if (banners.count) {
            [self.feeds addObject:banners];
        }
    }
    
    [super handleFeeds:responseObject pullingDown:pullingDown];
}

// 在这里处理松手后状态栏的状态
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint offset = self.collectionView.contentOffset;
    CGFloat offsetY = offset.y;
    if ( offsetY >= - QDNaviBarMaxY * 0.5 && offsetY <= 0) { // 顶部上一半
        CGPoint offset = self.collectionView.contentOffset;
        offset.y = 0;
        [self.collectionView setContentOffset:offset animated:YES];
        
    } else if ( offsetY > - QDNaviBarMaxY && offsetY < - QDNaviBarMaxY + QDNaviBarMaxY * 0.5) { // 顶部下一半
        CGPoint offset = self.collectionView.contentOffset;
        offset.y = - QDNaviBarMaxY;
        [self.collectionView setContentOffset:offset animated:YES];
    }
    
    // 父类有侧边菜单按钮定时器的处理
    [super scrollViewDidEndDecelerating:scrollView];
}

@end
