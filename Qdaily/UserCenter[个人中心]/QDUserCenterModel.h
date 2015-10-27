//
//  QDUserCenterModel.h
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDUserCenterModel : NSObject
// 绑定开关
/** 微信 */
@property (nonatomic, assign)  BOOL wechat;
/** 微博 */
@property (nonatomic, assign)  BOOL weibo;
/** QQ */
@property (nonatomic, assign)  BOOL qq;
/** 用户再服务器上的 ID */
@property (nonatomic, copy) NSString *user_id;
/** 用户在服务器上的名字 */
@property (nonatomic, copy) NSString *username;
/** 用户保存服务器上的头像地址 */
@property (nonatomic, copy) NSString *face;

/** 五边形数据数组 */
@property (nonatomic, strong)  NSMutableArray *genes;
@end
