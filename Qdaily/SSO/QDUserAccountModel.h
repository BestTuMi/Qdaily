//
//  QDUserAccountModel.h
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

#define QDUserAccountFilePath [(NSString *)(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)).lastObject stringByAppendingPathComponent:@"userAccount.plist"]

typedef NS_ENUM(NSInteger, QDLoginType) {
    QDLoginTypeWeibo = 1,
    QDLoginTypeQQ
};

@interface QDUserAccountModel : NSObject
/** token */
@property (nonatomic, copy) NSString *token;
/** uid */
@property (nonatomic, copy) NSString *uid;
/** 用户名 */
@property (nonatomic, copy)  NSString *username;
/** 头像地址 */
@property (nonatomic, copy)  NSString *face;
/** 过期日期 */
@property (nonatomic, strong) NSDate *expirationDate;
/** 账户存储路径 */
@property (nonatomic, copy)  NSString *filePath;
/** 登录类型 */
@property (nonatomic, assign) QDLoginType type;
// 保存用户模型到文件
- (BOOL)saveUserAccount;
@end
