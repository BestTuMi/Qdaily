//
//  UIView+Extension.h
//  Qdaily
//
//  Created by Envy15 on 15/9/26.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Extension)
/** x 值 */
@property (nonatomic, assign)  CGFloat x;
/** y 值 */
@property (nonatomic, assign)  CGFloat y;
/**  宽度 值 */
@property (nonatomic, assign)  CGFloat width;
/** 高度 值 */
@property (nonatomic, assign)  CGFloat height;
/** 中点的 X 值 */
@property (nonatomic, assign)  CGFloat centerX;
/** 中点的 y 值 */
@property (nonatomic, assign)  CGFloat centerY;

/*!
 *  @brief  添加一个半透明模糊层
 *
 *  @param alpha 透明程度
 */
- (void)addBlurViewWithAlpha: (CGFloat)alpha;
- (void)addBlurViewWithFrame: (CGRect)frame;
@end
