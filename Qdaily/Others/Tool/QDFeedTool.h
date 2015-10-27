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
 *  @brief  请求新的新闻数据
 *
 *  @param path     请求路径
 *  @param lasttime 服务器需要的分页参数
 *  @param finished 完成后的回调
 */
- (void)loadFeedsWithPath:(NSString *)path lasttime:(NSString *)lasttime finished:(FinishedBlock)finished;
/*!
 *  @brief  需要参数的GET 请求
 *
 *  @param path       请求路径
 *  @param parameters 请求参数
 *  @param finished   完成后的回调
 */
- (void)loadFeedsWithPath:(NSString *)path parameters:(NSDictionary *)parameters finished:(FinishedBlock)finished;


@end
