//
//  QDMainRootViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDMainRootViewController.h"
#define SideMenuKeyPath @"frame"

@interface QDMainRootViewController () <UIGestureRecognizerDelegate>
/** 侧边菜单视图 */
@property (nonatomic, weak)  UIView *sideMenuView;
/** 中间主视图 */
@property (nonatomic, weak) UIView *mainView;
/** 侧边菜单按钮 */
@property (nonatomic, weak)  UIButton *sideMenuButton;
/** 菜单是否在屏幕上 */
@property (nonatomic, assign) BOOL isMenuVisibele;
@end

@implementation QDMainRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMainView];
    [self setupsideMenuView];
    // 侧边按钮如果跟菜单在同一 View 会影响边缘手势范围.因此独立出来
    [self setupSideMenuButton];
}

- (void)dealloc {
    // 移除监听
    [self.sideMenuView removeObserver:self forKeyPath:SideMenuKeyPath];
}

#pragma mark - 设置主视图
- (void)setupMainView {
    UIView *mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    mainView.backgroundColor = QDRandomColor;
    
    // 添加边缘滑动手势
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    // 滑动范围为左侧
    edgePanGesture.edges = UIRectEdgeLeft;
    [mainView addGestureRecognizer:edgePanGesture];

    [self.view addSubview:mainView];
    _mainView = mainView;
}

#pragma mark - 设置左侧菜单视图
- (void)setupsideMenuView {
    UIView *sideMenuView = [[UIView alloc] init];
    
    // 宽度为屏幕宽的80%
    CGFloat sideMenuViewW = QDScreenW * 0.8;
    CGFloat sideMenuViewX = - sideMenuViewW;
    sideMenuView.frame = CGRectMake(sideMenuViewX, 0, sideMenuViewW, QDScreenH);
    
    // 使用 KVO 监听左侧菜单 Frame 变化,并改变菜单按钮 Frame 和其他值
    [sideMenuView addObserver:self forKeyPath:SideMenuKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // 添加滑动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [sideMenuView addGestureRecognizer:panGesture];
    
    [self.view addSubview:sideMenuView];
    sideMenuView.backgroundColor = QDRandomColor;
    _sideMenuView = sideMenuView;
}

#pragma mark - 侧边菜单按钮
- (void)setupSideMenuButton {
    UIButton *sideMenuButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    sideMenuButton.x = 15;
    sideMenuButton.width = 37;
    sideMenuButton.height = 37;
    sideMenuButton.y = QDScreenH - 15 - sideMenuButton.height;
    
    // 添加点击事件
    [sideMenuButton addTarget:self action:@selector(showSideMenu) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sideMenuButton];
    _sideMenuButton = sideMenuButton;
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat new = [change[NSKeyValueChangeNewKey] CGRectValue].origin.x;
    CGFloat old = [change[NSKeyValueChangeOldKey] CGRectValue].origin.x;
    CGFloat offsetX = new - old;

    self.sideMenuButton.x += offsetX;
}

#pragma mark - 显示隐藏左侧菜单
- (void)showSideMenu {
    _isMenuVisibele = !_isMenuVisibele;
    self.sideMenuView.x = _isMenuVisibele ? 0 : - self.sideMenuView.width;
}

#pragma mark - 滑动显示左侧菜单
- (void)pan: (UIPanGestureRecognizer *)panGesture {
    // 获取偏移值(在手势所在的视图)
    CGPoint offsetP = [panGesture translationInView:panGesture.view];
    CGFloat offsetX = offsetP.x;
    
    // 改变菜单 frame
    _sideMenuView.x += offsetX;
    
    // TODO: 增加蒙版
    
    // 复位
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    
    // 改变菜单的 frame
    [self sideMenuFrameWithOffsetX:offsetX panGetsture:panGesture];
    
}

#pragma mark - 计算菜单的 Frame
/*!
 *  @brief   手势滑动时计算侧边菜单的 frame
 *
 *  @param offsetX     手势滑动时的 x 偏移量
 *  @param panGetsture 使用的手势,包括平移和边缘平移滑动
 *
 */
- (void)sideMenuFrameWithOffsetX: (CGFloat)offsetX panGetsture: (UIPanGestureRecognizer *)panGetsture {
    CGFloat sideMenuMaxX = CGRectGetMaxX(_sideMenuView.frame);
    if (sideMenuMaxX >= _sideMenuView.width) { // 左边达到边缘后不再改变 Frame
        _sideMenuView.x = 0;
    } else if (sideMenuMaxX <= 0) { // 右侧到达边缘后,也不再改变 frame
        _sideMenuView.x = - _sideMenuView.width;
    }
    
#warning 未完成
    // TODO: 完成减速动画
    if (panGetsture.state == UIGestureRecognizerStateEnded || panGetsture.state == UIGestureRecognizerStateCancelled) {
        // 根据手势停止时速度向量判断手势方向
        CGFloat velocityX = [panGetsture velocityInView:panGetsture.view].x;
        
        if (sideMenuMaxX >= 44 && velocityX > 0) { // 向右滑动达到一定距离
            // 显示完整菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideMenuView.x = 0;
            }];
        } else if (sideMenuMaxX >= (_sideMenuView.width - 44) && velocityX < 0) { // 向左滑动距离不足
            // 显示完整菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideMenuView.x = 0;
            }];
        } else {
            // 隐藏菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideMenuView.x = - _sideMenuView.width;
            }];
        }
    }
}

#pragma mark - UIGestureRecognizerDelegate


@end
