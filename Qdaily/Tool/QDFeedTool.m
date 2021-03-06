//
//  QDFeedTool.m
//  Qdaily
//
//  Created by Envy15 on 15/10/11.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedTool.h"

@implementation QDFeedTool

+ (instancetype)sharedFeedTool {
    static QDFeedTool *_sharedFeedTool = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedFeedTool = [[self alloc] initWithBaseURL:QDBaseURL];
    });
    return _sharedFeedTool;
}

/// 取消任务
- (void)cancel {
    [[QDFeedTool sharedFeedTool].tasks makeObjectsPerformSelector:@selector(cancel)];
}

- (void)loadFeedsWithPath:(NSString *)path parameters:(NSDictionary *)parameters finished:(FinishedBlock)finished {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@", path];
    
    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        // 处理错误
        // 有响应, 无response 字段可能是登录失败
        if (responseObject[@"response"] == [NSNull null]) {
            NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        
        // 有返回的数据
        finished(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finished(nil, error);
    }];
}

- (void)get: (NSString *)urlStr finished: (FinishedBlock)finished {
    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:nil progress:nil success:^
        (NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
     // 处理错误
        if (responseObject[@"response"] == [NSNull null]) {
             NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        
        finished(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil, error);
    }];
}

- (void)praiseWithPostId: (NSInteger)Id isCancel: (BOOL)isCancel finished: (FinishedBlock)finished {
    NSInteger genre = isCancel ? 2 : 1;
    NSDictionary *params = @{
                             @"genre" : @(genre),
                             @"id" : @(Id),
                             @"praise_type" : @"article"
                             };
    NSString *urlStr = @"/app/praises/create_praise";
    [[QDFeedTool sharedFeedTool] POST:urlStr parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 处理错误
        if (responseObject[@"response"] == [NSNull null]) {
            NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        finished(responseObject, nil);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        finished(nil, error);
    }];
}

@end
