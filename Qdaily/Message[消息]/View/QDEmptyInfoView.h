//
//  QDEmptyInfoView.h
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDEmptyInfoView : UIView
// 设置标题
@property (nonatomic, copy) NSString *title;
// 隐藏图标文字
- (void)hideEmptyViewInfo;
// 显示图标文字
- (void)showEmptyViewInfo;
/// 调整内容位置(进能调节 Y 轴,相当于 top 约束)
- (void)setContentPosition: (CGPoint)position;
@end
