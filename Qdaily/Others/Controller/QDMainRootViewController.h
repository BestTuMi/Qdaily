//
//  QDMainRootViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDMainRootViewController : UIViewController
/*!
 *  @brief  显示隐藏侧边菜单
 */
- (void)showSideBar;
/*!
 *  @brief  隐藏侧边菜单
 */
- (void)hideSideBar;
/*!
 *  @brief  改变主视图上的视图
 */
- (void)setMainViewChildVc:(UIViewController *)mainViewChildVc;
@end
