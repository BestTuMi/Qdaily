//
//  QDUserCenterVM.m
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDUserCenterVM.h"
#import "QDUserCenterModel.h"
#import "QDRadarData.h"
#import <MJExtension.h>

@interface QDUserCenterVM ()
@end

@implementation QDUserCenterVM

+ (instancetype)sharedInstance {
    static QDUserCenterVM *_userCenterVM = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userCenterVM = [[self alloc] init];
    });
    return _userCenterVM;
}

- (void)loadGenesData: (void (^)(NSDictionary *responseObject, NSError *error))finished {
    NSString *urlStr = @"/app/users/radar?";
    [[QDFeedTool sharedFeedTool] GET:urlStr parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // 验证数据
        if (responseObject[@"response"] == [NSNull null]) {
            NSString *status = responseObject[@"meta"][@"status"];
            finished(nil, [NSError errorWithDomain:@"com.qdaily.app" code:status.integerValue userInfo:responseObject[@"meta"]]);
            return;
        }
        
        // 处理数据
        NSArray *genes = [QDRadarData objectArrayWithKeyValuesArray:responseObject[@"response"]];
        // 注意创建五边形时顶点要与数据对应起来
        [self.userCenterModel.genes addObject:genes[3]];
        [self.userCenterModel.genes addObject:genes[2]];
        [self.userCenterModel.genes addObject:genes[1]];
        [self.userCenterModel.genes addObject:genes[0]];
        [self.userCenterModel.genes addObject:genes[4]];
        
        finished(responseObject, nil);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        finished(nil, error);
    }];
}

@end
