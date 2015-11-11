//
//  QDFeedBaseViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/11/5.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDCollectionView;
@class QDFeedLayout;

@interface QDFeedBaseViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate>

/** collectionView */
@property (nonatomic, weak) QDCollectionView *collectionView;
/** collectionView 布局 */
@property (nonatomic, strong) QDFeedLayout *flowLayout;
/** Feeds 保存所有模型数据 */
@property (nonatomic, strong) NSMutableArray *feeds;

/****** 以下属性上拉加载数据时使用 *******/
/** 是否有更多数据 */
@property (nonatomic,  assign) BOOL has_more;
/** 请求更多数据时传的值 */
@property (nonatomic,  copy) NSString *last_time;

/** 请求的地址 */
- (NSString *)requestUrl;
- (NSDictionary *)parameters;
- (void)handleFeeds: (NSDictionary *)responseObject pullingDown: (BOOL)pullingDown;

/// 初始 feeds 数据
- (void)setupFeeds;
/// 加载更多数据
- (void)loadMoreNews;
/// 从网络加载更多数据
- (void)loadMoreFeedsFromNetWork;

/*!
 *  @brief  重置 collectionView, 包括数据和滚动位置
 */
- (void)resetAll;
@end
