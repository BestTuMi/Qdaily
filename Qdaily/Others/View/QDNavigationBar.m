//
//  QDNavigationBar.m
//  Qdaily
//
//  Created by Envy15 on 15/10/20.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNavigationBar.h"

@implementation QDNavigationBar

+ (void)initialize {
    // 置空导航条原有背景图
    UINavigationBar *naviBar = [UINavigationBar appearance];
    [naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [naviBar setShadowImage:[[UIImage alloc] init]];
    
    // 添加一个 toolBar 做毛玻璃效果
    [naviBar addBlurViewWithFrame:CGRectMake(0, - QDStatusBarH, QDScreenW, QDNaviBarMaxY)];
}

@end
