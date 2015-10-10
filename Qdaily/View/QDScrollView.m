//
//  QDScrollView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/9.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDScrollView.h"
#import "QDMainRootViewController.h"
#import "QDNavigationController.h"

@interface QDScrollView () <UIGestureRecognizerDelegate>

@end

@implementation QDScrollView

#pragma mark - 手势拦截层手势
- (void)setupGestureV {
    // 添加手势拦截层
    // 通过 addsubView 提到最前

    UIView *placeholderV = [[UIView alloc] init];
    placeholderV.frame = CGRectMake(0, 0, self.width, self.height);
    
    //添加手势
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    edgePanGesture.edges = UIRectEdgeLeft;
    
    // 设置手势代理
    edgePanGesture.delegate = self;
    
    // 接管 ScrollView 的 Pan 手势
    [placeholderV addGestureRecognizer:self.panGestureRecognizer];
    
    // 添加手势
    [placeholderV addGestureRecognizer:edgePanGesture];
    
    [self.superview addSubview:placeholderV];
}

#pragma mark - 拦截手势调用此方法
- (void)pan: (UIPanGestureRecognizer *)panGesture {
    QDMainRootViewController *mainRootVc = ((QDNavigationController *)(self.window.rootViewController)).viewControllers[0];
    // 调用根控制器的手势方法
    [mainRootVc performSelector:@selector(pan:) withObject:panGesture];
}

/*!
 *  @brief  调用 Pan 的时候禁用边缘滑动
 *
 *  @param gestureRecognizer      当前手势
 *  @param otherGestureRecognizer 其他手势
 *
 *  @return 是否需要另外的手势进入失败状态
 */
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRequireFailureOfGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        return NO;
    } else {
        return YES;
    }
}

@end
