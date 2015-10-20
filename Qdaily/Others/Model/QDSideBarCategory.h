//
//  QDSideMenuCategory.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDSideBarCategory : NSObject
/** 目录的 ID 号 */
@property (nonatomic, copy) NSString *ID;
/** 目录标题 */
@property (nonatomic, copy)  NSString *title;
/** 图标 */
@property (nonatomic, copy)  NSString *image;
/** 高亮图标 */
@property (nonatomic, copy)  NSString *image_highlighted;
/** 目标控制器 */
@property (nonatomic, assign)  Class destVcClass;
/** 信息流模型数组 */
@property (nonatomic, strong)  NSMutableArray *feeds;
@end
