//
//  QDCustomNaviBar.h
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDCustomNaviBar : UIView
/** 标题View */
@property (nonatomic, weak) UILabel *titleView;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/*!
 *  @brief  构造方法
 *
 *  @param title 标题
 *
 *  @return 返回实例对象
 */
+ (instancetype)naviBarWithTitle: (NSString *)title;
- (void)setAttributedTitle: (NSAttributedString *)attributedTitle;
@end
