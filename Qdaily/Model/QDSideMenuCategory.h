//
//  QDSideMenuCategory.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDSideMenuCategory : NSObject
/** 目录标题 */
@property (nonatomic, copy)  NSString *title;
/** 图标 */
@property (nonatomic, copy)  NSString *iconName;
/** 目标控制器 */
@property (nonatomic, assign)  Class destVcClass;
/** 信息流模型数组 */
@property (nonatomic, strong)  NSMutableArray *feeds;
@end
