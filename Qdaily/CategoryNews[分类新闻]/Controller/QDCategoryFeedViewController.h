//
//  QDCategoryFeedViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDBaseFeedViewController.h"

@interface QDCategoryFeedViewController : QDBaseFeedViewController
/** 目录的 ID 号 */
@property (nonatomic, copy) NSString *ID;
/** 目录的 categoryTitle */
@property (nonatomic, copy) NSString *categoryTitle;

@end
