//
//  QDFeedCacheTool.h
//  Qdaily
//
//  Created by Envy15 on 15/11/3.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDFeedCacheTool : NSObject

/*!
 *  @brief  缓存首页数据
 *
 *  @param dict 网络工具返回的原始数据
 */
+ (void)cacheHomeFeeds:(NSDictionary *)dict;

/*!
 *  @brief  缓存实验室数据
 *
 *  @param dict 网络工具返回的原始数据
 */
+ (void)cacheLabFeeds:(NSDictionary *)dict;

/*!
 *  @brief  缓存分类新闻数据
 *
 *  @param dict 网络工具返回的原始数据
 *  @param dict 在左侧菜单中的分类Id
 */
+ (void)cacheCategoryFeeds:(NSDictionary *)dict categoryId: (NSInteger)categoryId;

/*!
 *  @brief  从缓存加载首页数据
 *
 *  @param last_time 最后一个帖子的 publish_time
 *  @param filter     其他查询条件,可传空
 *  @param completed 完成后的回调
 */
+ (void)loadHomeFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed;

/*!
 *  @brief  从缓存加载实验室数据
 *
 *  @param last_time 最后一个帖子的 publish_time
 *  @param filter    其他查询条件,可传空
 *  @param completed 完成后的回调
 */
+ (void)loadLabFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed;

/*!
 *  @brief  从缓存加载分类新闻数据
 *
 *  @param last_time 最后一个帖子的 publish_time
 *  @param filter     分类 Id
 *  @param completed 完成后的回调
 */
+ (void)loadCategoryFeedsCachesWithLastTime: (NSString *)last_time filter: (id)filter completed: (void (^)(NSArray *feeds))completed;

@end
