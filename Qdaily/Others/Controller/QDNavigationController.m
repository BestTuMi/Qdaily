//
//  QDNavigationController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNavigationController.h"
#import "QDNavigationBar.h"
#import "objc/runtime.h"

@interface QDNavigationController () <UIGestureRecognizerDelegate>

@end

@implementation QDNavigationController

+ (void)load {
//    unsigned int count = 0;
//    Ivar *ivars = class_copyIvarList([UINavigationController class], &count);
//    for (int i = 0; i < count; i++) {
//        QDLogVerbose(@"%s", ivar_getName(ivars[i]));
//    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 替换原有的导航条
    QDNavigationBar *naviBar = [[QDNavigationBar alloc] init];
    [self setValue:naviBar forKeyPath:@"navigationBar"];
    
    // 添加一个手势
    id target = self.interactivePopGestureRecognizer.delegate;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:target action:@selector(handleNavigationTransition:)];
    [self.view addGestureRecognizer:pan];
    // 禁用系统自带边缘滑动手势
    self.interactivePopGestureRecognizer.enabled = NO;
    // 设置手势代理(避免根控制器滑动时及其他 bug)
    pan.delegate = self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (self.childViewControllers.count == 1) { // 根控制器
        return NO;
    }
    else {
        return YES;
    }
}

@end
