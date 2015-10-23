//
//  QDNavigationBar.m
//  Qdaily
//
//  Created by Envy15 on 15/10/20.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNavigationBar.h"
#import "objc/runtime.h"

@implementation QDNavigationBar

//+ (void)load {
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UINavigationBar class], &count);
//    for (int i = 0; i < count; i++) {
//        QDLogVerbose(@"%s", ivar_getName(ivars[i]));
//    }
//}

+ (void)initialize {
    // 置空导航条原有背景图
    UINavigationBar *naviBar = [UINavigationBar appearance];
    [naviBar setBackgroundImage:[[UIImage alloc] init] forBarMetrics:UIBarMetricsDefault];
    [naviBar setShadowImage:[[UIImage alloc] init]];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // 添加一个 toolBar 做毛玻璃效果
        [self addBlurViewWithFrame:CGRectMake(0, - QDStatusBarH, QDScreenW, QDNaviBarMaxY) clip:NO];
    }
    return self;
}

@end
