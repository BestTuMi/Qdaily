//
//  QDFavouriteViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDCategoryFeedViewController.h"
@class QDSideBarCategory;

@interface QDFavouriteViewController : UIViewController
/** 当前分类 */
@property (nonatomic, strong)  QDSideBarCategory *category;
@end
