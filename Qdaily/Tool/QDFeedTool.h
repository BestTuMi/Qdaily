//
//  QDFeedTool.h
//  Qdaily
//
//  Created by Envy15 on 15/10/11.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>

typedef void(^FinishedBlock)(NSDictionary *responseObject, NSError *error);

@interface QDFeedTool : AFHTTPSessionManager

/// 创建网络工具单例
+ (instancetype)sharedFeedTool;
/// 取消任务
- (void)cancel;
/*!
 *  @brief  需要参数的GET 请求
 *
 *  @param path       请求路径
 *  @param parameters 请求参数
 *  @param finished   完成后的回调
 */
- (void)loadFeedsWithPath:(NSString *)path parameters:(NSDictionary *)parameters finished:(FinishedBlock)finished;

/*!
 *  @brief  GET 请求
 *
 *  @param urlStr   请求地址
 *  @param finished 完成后的回调
 */
- (void)get: (NSString *)urlStr finished: (FinishedBlock)finished;

/*!
 *  @brief  点赞或取消点赞
 *
 *  @param Id       点赞的新闻的 ID
 *  @param isCancel  是否是取消点赞
 *  @param finished 完成后的回调
 */
- (void)praiseWithPostId: (NSInteger)Id isCancel: (BOOL)isCancel finished: (FinishedBlock)finished;
@end
