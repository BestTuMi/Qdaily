//
//  QDUserAccountViewModel.h
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDUserAccountModel;

@interface QDUserAccountViewModel : NSObject


/** 授权模型 */
@property (nonatomic, strong) QDUserAccountModel *userAccountModel;

/*!
 *  @brief  单例
 */
+ (instancetype)sharedInstance;
/*!
 *  @brief  登录微博
 *  @param weakPresentingVc     用来modal出登录界面的控制器
 *  @param finished             完成后的回调
 */

/*!
 *  @brief  是否可以使用保存的授权模型直接登录,而不用再经过 SSO 拿 access Token
 */
- (BOOL)canLogin;

- (RACSignal *)weiboLoginWithViewController: (__weak UIViewController *)weakPresentingVc;

/*!
 *  @brief  登录服务器
 *
 *  @param userAccount  用户模型
 *  @param finished   完成后的回调
 */
- (void)login: (QDUserAccountModel *)userAccount finished:(FinishedBlock)finished;

@end
