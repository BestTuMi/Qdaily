//
//  QDCategoryFeedViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDBaseFeedViewController.h"
@class QDSideBarCategory;

@interface QDCategoryFeedViewController : UIViewController
/** 当前分类 */
@property (nonatomic, strong)  QDSideBarCategory *category;
/** 所有分类 */
@property (nonatomic, strong) NSMutableDictionary *categories;

@end
