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

- (void)loadFeedsWithPath:(NSString *)path lasttime:(NSString *)lasttime finished:(void (^)(NSDictionary *responseObject, NSError *error))finished {
    
    // 取消之前的请求
    [[QDFeedTool sharedFeedTool] cancel];
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@.json?", path, lasttime];
    QDLogVerbose(@"%@", urlStr);
    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        
        QDLogVerbose(@"%@", responseObject);
        
        // 处理错误
        // 有响应, 无response 字段可能是登录失败
        if (responseObject[@"response"] == [NSNull null]) {
            NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        
        // 有返回的数据
        finished(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil, error);
    }];
}

- (void)loadFeedsWithPath:(NSString *)path parameters:(NSDictionary *)parameters finished:(void (^)(NSDictionary *responseObject, NSError *error))finished {
    
    NSString *urlStr = [NSString stringWithFormat:@"%@", path];
    
    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        
        QDLogVerbose(@"%@", responseObject);
        
        // 处理错误
        // 有响应, 无response 字段可能是登录失败
        if (responseObject[@"response"] == [NSNull null]) {
            NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        
        // 有返回的数据
        finished(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil, error);
    }];
}

@end
