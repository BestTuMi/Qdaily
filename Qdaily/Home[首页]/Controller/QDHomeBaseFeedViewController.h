//
//  QDBaseFeedViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QDFeedBaseViewController.h"
#import "QDFeedCacheTool.h"
@class QDCollectionView;

@interface QDHomeBaseFeedViewController : QDFeedBaseViewController
/** 是否显示 navibar */
@property (nonatomic, assign) BOOL naviBarHidden;
/** 蒙版层 */
@property (nonatomic, weak) UIView *maskView;
@end
