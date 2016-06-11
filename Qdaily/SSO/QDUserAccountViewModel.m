//
//  QDUserAccountViewModel.m
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDUserAccountViewModel.h"
#import "QDUserAccountModel.h"
#import "UMSocial.h"

@interface QDUserAccountViewModel ()
@end

@implementation QDUserAccountViewModel

+ (instancetype)sharedInstance {
    static QDUserAccountViewModel *_userAccountViewModel = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _userAccountViewModel = [[self alloc] init];
    });
    return _userAccountViewModel;
}

/*!
 *  @brief  初始化时加载用户授权信息
 */
- (instancetype)init {
    self = [super init];
    if (self) {
       self.userAccountModel = [self loadUserAccount];
    }
    return self;
}

// 能否用存储的信息登录
- (BOOL)canLogin {
    if (self.userAccountModel) {
        // 有授权模型而且没有过期
        return YES;
    } else {
        return NO;
    }
}

/*!
 *  @brief  初始化的时候即从文件中加载授权模型
 */
- (QDUserAccountModel *)loadUserAccount {
    
    if (self.userAccountModel != nil) { // 已经加载过
        return self.userAccountModel;
    }
    
    // 从文件中加载
    self.userAccountModel = [NSKeyedUnarchiver unarchiveObjectWithFile:QDUserAccountFilePath];
    // 如果没有保存过,直接返回,进行后续认证操作
    if (!self.userAccountModel || !self.userAccountModel.token) { // 或者存储有问题
        QDLogVerbose(@"%@", QDUserAccountFilePath);
        self.userAccountModel = nil;
        return nil;
    }
    
    // 保存过用户模型,接下来判断授权是否过期
    // 与当前日期进行比较
    NSDate *currentDate = [NSDate date];
    // 如果过期,去进行认证操作
    if ([currentDate compare:self.userAccountModel.expirationDate] == NSOrderedDescending) {
        self.userAccountModel = nil;
        return self.userAccountModel;
    }
    
    // 来到这表示授权过,且没有过期
    return self.userAccountModel;
}

- (RACSignal *)weiboLoginWithViewController:(UIViewController *__weak)weakPresentingVc {
    
    UMSocialSnsPlatform *snsPlatform = [UMSocialSnsPlatformManager getSocialPlatformWithName:UMShareToSina];
    
    @weakify(self);
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        snsPlatform.loginClickHandler(weakPresentingVc,[UMSocialControllerService defaultControllerService],YES,^(UMSocialResponseEntity *response){
            @strongify(self);
            // 验证数据
            if (response.responseCode == UMSResponseCodeNetworkError) {
                NSError *error = [NSError errorWithDomain:@"com.sina.weibo" code:response.responseCode userInfo:@{@"msg":@"网络错误"}];
                [subscriber sendError:error];
                return;
            }
    
            if (response.responseCode == UMSREsponseCodeTokenInvalid) {
                NSError *error = [NSError errorWithDomain:@"com.sina.weibo" code:response.responseCode userInfo:@{@"msg":@"授权用户token错误"}];
                [subscriber sendError:error];
                return;
            }
    
            if (response.responseCode == UMSResponseCodeBaned) {
                NSError *error = [NSError errorWithDomain:@"com.sina.weibo" code:response.responseCode userInfo:@{@"msg":@"用户被封禁"}];
                [subscriber sendError:error];
                return;
            }
    
            //  获取微博用户名、uid、token等
            if (response.responseCode == UMSResponseCodeSuccess) {
    
                UMSocialAccountEntity *snsAccount = [[UMSocialAccountManager socialAccountDictionary] valueForKey:UMShareToSina];
    
                // 设置模型
                QDUserAccountModel *userAccount = [[QDUserAccountModel alloc] init];
                userAccount.username = snsAccount.userName;
                userAccount.uid = snsAccount.usid;
                userAccount.token = snsAccount.accessToken;
                userAccount.face = snsAccount.iconURL;
                // 根据登录类型选择
                userAccount.type = 1;
                
                self.userAccountModel = userAccount;
                
                // 保存授权模型
                [self.userAccountModel saveUserAccount];
      
                // 完成
                [subscriber sendNext:userAccount];
                [subscriber sendCompleted];
            }});
        return nil;
    }];
}


- (void)login: (QDUserAccountModel *)userAccount finished:(FinishedBlock)finished {
    
    NSString *urlStr = @"/users/social_sign_in";
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"face"] = userAccount.face;
    params[@"source"] = @"AppStore";
    params[@"token"] = userAccount.token;
    params[@"type"] = @(userAccount.type);
    params[@"uid"] = userAccount.uid;
    params[@"username"] = userAccount.username;
    
    [[QDFeedTool sharedFeedTool] POST:urlStr parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
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
