//
//  QDCategoryFeedViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDFeedBaseViewController.h"
@class QDSideBarCategory;

@interface QDCategoryFeedViewController : QDFeedBaseViewController
/** 当前分类 */
@property (nonatomic, strong)  QDSideBarCategory *category;
/** 在阅读界面弹出时使用 */
@property (nonatomic, copy) NSDictionary *params;
/** 弹出类型 */
@property (nonatomic, copy)  NSString *type;
@end
