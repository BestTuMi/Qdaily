//
//  QDUserCenterVM.h
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDUserCenterModel;

@interface QDUserCenterVM : NSObject
/** 用户中心的模型 */
@property (nonatomic, strong) QDUserCenterModel *userCenterModel;

+ (instancetype)sharedInstance;

/*!
 *  @brief  加载 genes 的数据(五边形)
 *
 *  @param finished 完成后的回调
 */
- (void)loadGenesData: (void (^)(NSDictionary *responseObject, NSError *error))finished;
@end
