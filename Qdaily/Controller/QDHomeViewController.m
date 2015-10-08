//
//  QDHomeViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeViewController.h"

@interface QDHomeViewController ()
/** ScrollView */
@property (nonatomic, weak) UIView *scrollView;
/** Q 选项 */
@property (nonatomic, weak)  UIButton *qButton;
/** Lab 选项 */
@property (nonatomic, weak)  UIButton *labButton;
/** 选项底部指示器 */
@property (nonatomic, weak)  UIView *indicator;
/** 记录当前选中按钮 */
@property (nonatomic, weak)  UIButton *selectedButton;
@end

@implementation QDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupScrollView];
    
    [self setupNaviBar];

}

#pragma mark - 设置 ScrollView
- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    scrollView.backgroundColor = QDRGBWhiteColor(1.0, 1.0);
    [self.view addSubview:scrollView];
}

#pragma mark - 设置顶部自定义导航条
- (void)setupNaviBar {
    UIView *naviBar = [[UIView alloc] init];
    naviBar.frame = CGRectMake(0, 0, QDScreenW, QDNaviBarMaxY);
    [self.view addSubview:naviBar];
    
    // 添加透明模糊层
    [naviBar addBlurViewWithAlpha:0.7];
    
    // 添加选项卡按钮
    UIButton *qButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [qButton setImage:[UIImage imageNamed:@"home_tab_q"] forState:UIControlStateNormal];
    [qButton setImage:[UIImage imageNamed:@"home_tab_q_h"] forState:UIControlStateDisabled];
    
    // 取消按钮高亮
    qButton.adjustsImageWhenHighlighted = NO;
    
    [naviBar addSubview:qButton];
    self.qButton = qButton;
    
    // 添加点击事件
    [qButton addTarget:self action:@selector(updateTabStatus:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *labButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab"] forState:UIControlStateNormal];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab_h"] forState:UIControlStateDisabled];
    
    // 取消按钮高亮
    labButton.adjustsImageWhenHighlighted = NO;
    
    [naviBar addSubview:labButton];
    self.labButton = labButton;
    
    // 添加点击事件
    [labButton addTarget:self action:@selector(updateTabStatus:) forControlEvents:UIControlEventTouchUpInside];
    

    // 设置按钮的 Frame
    CGFloat buttonW = QDScreenW * 0.5;
    CGFloat buttonH = QDNaviBarH;
    CGFloat buttonY = QDStatusBarH;
    CGFloat buttonX = 0;
    qButton.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
    labButton.frame = CGRectMake(buttonW, buttonY, buttonW, buttonH);
    
    // 设置指示器
    UIView *indicator = [[UIView alloc] init];
    indicator.backgroundColor = QDHighlightColor;
    indicator.width = buttonW * 0.5;
    indicator.height = 3;
    indicator.y = QDNaviBarMaxY - indicator.height;
    [naviBar addSubview:indicator];
    self.indicator = indicator;
    
     // 默认选中第一个
    qButton.enabled = NO;
    indicator.centerX = qButton.centerX;
    self.selectedButton = qButton;
}

#pragma mark - 更新选项卡状态(包括指示器位置)
- (void)updateTabStatus: (UIButton *)button {
    // 更改按钮选中状态
    button.enabled = !button.enabled;
    // 修改之前选中按钮的状态
    self.selectedButton.enabled = YES;
    
    // 更改指示器的位置
    [UIView animateWithDuration:0.25 animations:^{
        self.indicator.centerX = button.centerX;
    }];
    
    // 记录当前选中按钮
    self.selectedButton = button;
}


@end
