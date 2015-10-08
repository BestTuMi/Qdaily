//
//  UIView+Extension.m
//  Qdaily
//
//  Created by Envy15 on 15/9/26.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
- (void)setX:(CGFloat)x {
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)x {
    return self.frame.origin.x;
}

- (void)setY:(CGFloat)y {
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)y {
    return self.frame.origin.y;
}

- (void)setWidth:(CGFloat)width {
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)width {
    return self.frame.size.width;
}

- (void)setHeight:(CGFloat)height {
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)height {
    return self.frame.size.height;
}

- (void)setCenterX:(CGFloat)centerX {
    CGPoint center = self.center;
    center.x = centerX;
    self.center = center;
}

- (CGFloat)centerX {
    return self.center.x;
}

- (void)setCenterY:(CGFloat)centerY {
    CGPoint center = self.center;
    center.y = centerY;
    self.center = center;
}

- (CGFloat)centerY {
    return self.center.y;
}

/*!
 *  @brief  添加一个半透明模糊层,需要设置后面层级的背景为透明
 *
 *  @param alpha 透明程度
 */
- (void)addBlurViewWithAlpha: (CGFloat)alpha {
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    visualEffectView.frame = self.bounds;
    
    // 黑色遮罩
    UIView *maskView = [[UIView alloc] initWithFrame:visualEffectView.bounds];
    maskView.backgroundColor = [UIColor blackColor];
    maskView.alpha = alpha;
    [visualEffectView.contentView addSubview:maskView];
    
    // 添加为子控件
    [self addSubview:visualEffectView];
}

@end
