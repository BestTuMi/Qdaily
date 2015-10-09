//
//  QDHomeViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeViewController.h"
#import "QDHomeFeedArticleViewController.h"
#import "QDHomeLabFeedViewController.h"

@interface QDHomeViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
/** ScrollView */
@property (nonatomic, weak) UIScrollView *scrollView;
/** Q 选项 */
@property (nonatomic, weak)  UIButton *qButton;
/** Lab 选项 */
@property (nonatomic, weak)  UIButton *labButton;
/** 选项底部指示器 */
@property (nonatomic, weak)  UIView *indicator;
/** 记录当前选中按钮 */
@property (nonatomic, weak)  UIButton *selectedButton;
/** 首页文章控制器 */
@property (nonatomic, strong)  QDHomeFeedArticleViewController *homeFeedVc;
/** 实验室控制器 */
@property (nonatomic, strong)  QDHomeLabFeedViewController *labFeedVc;
/** 将要显示的控制器 */
@property (nonatomic, weak)  UIViewController *willShowVc;
/** 选项卡按钮数组 */
@property (nonatomic, strong) NSMutableArray *tabButtons;

/** q 选项卡手势拦截层 */
@property (nonatomic, strong) UIView *qPlaceholderV;
/** 实验室选项卡手势拦截层 */
@property (nonatomic, strong) UIView *labPlaceholderV;
/** 手势拦截层数组 */
@property (nonatomic, strong)  NSMutableArray *gestureVArray;

@end

@implementation QDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 设置背景色
    self.view.backgroundColor = QDLightGrayColor;
    
    [self setupChildVc];
    
    [self setupScrollView];
    
    [self setupNaviBar];

}

#pragma mark -
#pragma mark - lazyload
- (QDHomeFeedArticleViewController *)homeFeedVc {
    if (!_homeFeedVc) {
        _homeFeedVc = [[QDHomeFeedArticleViewController alloc] init];
    }
    return _homeFeedVc;
}

- (QDHomeLabFeedViewController *)labFeedVc {
    if (!_labFeedVc) {
        _labFeedVc = [[QDHomeLabFeedViewController alloc] init];
    }
    return _labFeedVc;
}

- (NSMutableArray *)tabButtons {
    if (!_tabButtons) {
        _tabButtons = [NSMutableArray array];
    }
    return _tabButtons;
}

- (NSMutableArray *)gestureVArray {
    if (!_gestureVArray) {
        _gestureVArray = [NSMutableArray array];
    }
    return _gestureVArray;
}

#pragma mark -
#pragma mark - 添加子控制器
- (void)setupChildVc {
    [self addChildViewController:self.homeFeedVc];
    [self addChildViewController:self.labFeedVc];
}

#pragma mark - 设置 ScrollView
- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    
    // 隐藏滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    // 取消回弹
    scrollView.bounces = 0;
    
    // 取消自动内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    // 设置分页
    scrollView.pagingEnabled = YES;
    
    // 设置代理
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    
    // 手势拦截层
    [self setupGestureV];
    
    NSInteger count = self.childViewControllers.count;
    scrollView.contentSize = CGSizeMake(QDScreenW * count, QDScreenH);
    
    // 默认选中首页,下面这个方法懒加载视图
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

#pragma mark - 手势拦截层手势
- (void)setupGestureV {
    // 添加手势拦截层
    // 创建两个占位容器视图,方便添加额外的手势
    // 通过 addsubView 提到最前
    UIView *qPlaceholderV = [[UIView alloc] init];
    qPlaceholderV.frame = CGRectMake(0, 0, self.scrollView.width, self.scrollView.height);
    
    //添加手势
    UIScreenEdgePanGestureRecognizer *qEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    qEdgePanGesture.edges = UIRectEdgeLeft;
    
    // 设置手势代理
    qEdgePanGesture.delegate = self;
    [qPlaceholderV addGestureRecognizer:qEdgePanGesture];
    
    [self.scrollView addSubview:qPlaceholderV];
    self.qPlaceholderV = qPlaceholderV;
    [self.gestureVArray addObject:qPlaceholderV];
    
    UIView *labPlaceholderV = [[UIView alloc] init];
    labPlaceholderV.frame = CGRectMake(self.scrollView.width, 0, self.scrollView.width, self.scrollView.height);
    [self.scrollView addSubview:labPlaceholderV];
    
    //添加手势
    UIScreenEdgePanGestureRecognizer *labEdgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    labEdgePanGesture.edges = UIRectEdgeLeft;
    
    // 设置手势代理
    labEdgePanGesture.delegate = self;
    [labPlaceholderV addGestureRecognizer:labEdgePanGesture];
    
    self.labPlaceholderV = labPlaceholderV;
    [self.gestureVArray addObject:labPlaceholderV];

}

#pragma mark - 拦截手势调用此方法
- (void)pan: (UIPanGestureRecognizer *)panGesture {
    [self.parentViewController performSelector:@selector(pan:) withObject:panGesture];
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
    [naviBar addSubview:qButton];
    [self.tabButtons addObject:qButton];
    self.qButton = qButton;

    UIButton *labButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab"] forState:UIControlStateNormal];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab_h"] forState:UIControlStateDisabled];
    [naviBar addSubview:labButton];
    [self.tabButtons addObject:labButton];
    self.labButton = labButton;
    
    
    // 设置按钮的 Frame
    NSInteger count = self.childViewControllers.count;
    CGFloat buttonW = 1.0 * QDScreenW / count;
    CGFloat buttonH = QDNaviBarH;
    CGFloat buttonY = QDStatusBarH;
    CGFloat buttonX = 0;
    
    for (NSInteger i = 0; i < count; i++) {
        
        UIButton *button = self.tabButtons[i];
        buttonX = buttonW * i;
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        
        // 取消按钮高亮
        button.adjustsImageWhenHighlighted = NO;
        
        // 添加点击事件
        [button addTarget:self action:@selector(updateTabStatus:) forControlEvents:UIControlEventTouchUpInside];
    }
    
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
    self.selectedButton.enabled = !self.selectedButton.enabled;
    
    // 更改指示器的位置
    [UIView animateWithDuration:0.25 animations:^{
        self.indicator.centerX = button.centerX;
    }];
    
    // 记录当前选中按钮
    self.selectedButton = button;
    
    // 计算 offset
    NSInteger index = [self.tabButtons indexOfObject:button];
    CGFloat offsetX = self.scrollView.width * index;
    
    // 更改Offset, 切换子控制器
    [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
}

#pragma mark - ScrollView Delegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 获取偏移值
    CGFloat offsetX = scrollView.contentOffset.x;
    
    // 计算 index
    NSInteger index = offsetX / scrollView.width;
    
    // 获取将要显示的控制器
    self.willShowVc = self.childViewControllers[index];
    
    // 懒加载视图
    if (self.willShowVc.isViewLoaded) { // 视图加载过
        // 把手势拦截层提到最前
        [scrollView addSubview:self.gestureVArray[index]];
        return;
    } else {
        // Frame
        self.willShowVc.view.frame = scrollView.bounds;
        // 添加到 ScrollView 上
        [scrollView addSubview:self.willShowVc.view];
        
        // 把手势拦截层提到最前
        if (self.gestureVArray.count) {
            [scrollView addSubview:self.gestureVArray[index]];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 懒加载子控制器视图
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 取出 index, 加快选项卡状态更新
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = 1.0 * offsetX / scrollView.width;
    [self updateTabStatus:self.tabButtons[index]];
}

#pragma mark - Gesture Delegate
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    // ScrollView 滚动后,即不在第一页
//    // 而且手势是边缘滑动时时只执行边缘滑动
//    QDLogVerbose(@"%@", gestureRecognizer);
//    QDLogVerbose(@"+++++++%@", self.gestureVArray[1]);
//    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
//        otherGestureRecognizer.enabled = NO;
//    } else {
//        otherGestureRecognizer.enabled = YES;
//    }
//    return YES;
//}

@end
