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
#import "QDScrollView.h"
#import "QDCollectionView.h"
#import "Masonry.h"

@interface QDHomeViewController () <UIScrollViewDelegate, UIGestureRecognizerDelegate>
/** ScrollView */
@property (nonatomic, weak) QDScrollView *scrollView;
/** 自定义的NaviBar */
@property (nonatomic, weak) UIView *naviBar;
/** naviBar content */
@property (nonatomic, weak) UIView *naviBarContentV;
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

/** 更新状态栏的状态 */
@property (nonatomic, assign)  BOOL statusBarHidden;
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

#pragma mark - 设置首页重新显示时,状态栏的行为
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 刷新状态栏
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - 刷新状态栏状态,让父控制器重新设置状态栏
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self setNeedsStatusBarAppearanceUpdate];
}

#pragma mark - dealloc
- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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

#pragma mark -
#pragma mark - 添加子控制器
- (void)setupChildVc {
    [self addChildViewController:self.homeFeedVc];
    [self addChildViewController:self.labFeedVc];
}

#pragma mark - 设置 ScrollView
- (void)setupScrollView {
    QDScrollView *scrollView = [[QDScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    
    // 隐藏滚动条
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    // 取消回弹
    scrollView.bounces = NO;
    
    // 设置分页
    scrollView.pagingEnabled = YES;
    
    // 设置代理
    scrollView.delegate = self;
    
    [self.view addSubview:scrollView];
    self.scrollView = scrollView;
    
    [scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    NSInteger count = self.childViewControllers.count;
    scrollView.contentSize = CGSizeMake(QDScreenW * count, QDScreenH);
    
    // 监听 offset 的改变,改变蒙版的透明度
    [scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // 默认选中首页,下面这个方法懒加载视图
    [self scrollViewDidEndScrollingAnimation:scrollView];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat newOffsetX = [change[NSKeyValueChangeNewKey] CGPointValue].x;
    self.homeFeedVc.maskView.alpha = newOffsetX / self.view.width * 0.88;
    self.labFeedVc.maskView.alpha = (1 - newOffsetX / self.view.width) * 0.88;
}

#pragma mark - 设置顶部自定义导航条
- (void)setupNaviBar {
    UIView *naviBar = [[UIView alloc] init];
    naviBar.frame = CGRectMake(0, 0, QDScreenW, QDNaviBarMaxY);
    [self.view addSubview:naviBar];
    self.naviBar = naviBar;

    // 添加透明模糊层
    [naviBar addBlurViewWithAlpha:0.5];
    
    // 添加内容视图
    UIView *naviBarContentV = [[UIView alloc] init];
    // 设置锚点
    naviBarContentV.layer.anchorPoint = CGPointMake(0.5, 1);
    naviBarContentV.frame = naviBar.bounds;
    [naviBar addSubview:naviBarContentV];
    self.naviBarContentV = naviBarContentV;
    
    // 添加选项卡按钮
    UIButton *qButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [qButton setImage:[UIImage imageNamed:@"home_tab_q"] forState:UIControlStateNormal];
    [qButton setImage:[UIImage imageNamed:@"home_tab_q_h"] forState:UIControlStateDisabled];
    [naviBarContentV addSubview:qButton];
    [self.tabButtons addObject:qButton];
    self.qButton = qButton;

    UIButton *labButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab"] forState:UIControlStateNormal];
    [labButton setImage:[UIImage imageNamed:@"home_tab_lab_h"] forState:UIControlStateDisabled];
    [naviBarContentV addSubview:labButton];
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
        [button addTarget:self action:@selector(selectTabButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 设置指示器
    UIView *indicator = [[UIView alloc] init];
    indicator.backgroundColor = QDHighlightColor;
    
    indicator.width = buttonW * 0.5;
    indicator.height = 3;
    indicator.y = QDNaviBarMaxY - indicator.height;
    [naviBarContentV addSubview:indicator];
    self.indicator = indicator;
    
     // 默认选中第一个
    qButton.enabled = NO;
    indicator.centerX = qButton.centerX;
    self.selectedButton = qButton;
    
    // 添加通知监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNaviBarStatus:) name:QDFeedCollectionViewOffsetChangedNotification object:nil];
}

#pragma mark - 更新选项卡状态(包括指示器位置)
- (void)selectTabButton: (UIButton *)button {
    
    // 更改按钮选中状态
    button.enabled = !button.enabled;
    // 修改之前选中按钮的状态
    self.selectedButton.enabled = !self.selectedButton.enabled;
    
    // 更改指示器的位置
    self.indicator.centerX = button.centerX;

    // 记录当前选中按钮
    self.selectedButton = button;
    
    // 计算 offset
    NSInteger index = [self.tabButtons indexOfObject:button];
    CGFloat offsetX = self.scrollView.width * index;
    
    // 更改Offset, 切换子控制器
    [self.scrollView setContentOffset:CGPointMake(offsetX, self.scrollView.contentOffset.y) animated:YES];
}

#pragma mark -
#pragma mark - 选择指定 Index 的选项
- (void)selectTabAtIndex:(NSInteger)index {
    [self selectTabButton:self.tabButtons[index]];
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
        return;
    } else {
    
        // 根据当前 naviBar 状态,判断初始化时是否隐藏导航条
        ((QDHomeLabFeedViewController *)self.willShowVc).naviBarHidden = self.statusBarHidden;
        
        // Frame
        self.willShowVc.view.frame = scrollView.bounds;
        
        // 添加到 ScrollView 上
        [scrollView addSubview:self.willShowVc.view];

    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 懒加载子控制器视图
    [self scrollViewDidEndScrollingAnimation:scrollView];
    
    // 取出 index, 加快选项卡状态更新
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = 1.0 * offsetX / scrollView.width;
    [self selectTabButton:self.tabButtons[index]];
}

#pragma mark - 改变 NaviBar 的属性
- (void)updateNaviBarStatus:(NSNotification *)note {
    
    CGPoint newOffset = [note.userInfo[NSKeyValueChangeNewKey] CGPointValue];
    
    CGPoint oldOffset = [note.userInfo[NSKeyValueChangeOldKey] CGPointValue];
    
    CGFloat offsetY = newOffset.y - oldOffset.y;

    if (newOffset.y > -QDNaviBarMaxY) {
        // 变化比例
        CGFloat sy = ((- newOffset.y) / QDNaviBarMaxY);
        CGFloat scaleSy = sy <= 0.7 ? 0.7 : sy;
        CGFloat alphaSy = sy <= 0.7 ? sy * 0.2 : sy;
        
        self.naviBarContentV.transform = CGAffineTransformMakeScale(scaleSy, scaleSy);
        self.naviBarContentV.alpha = alphaSy;
    
        if (newOffset.y <= 0) { // naviBar消失之前 或 即将下拉出现
            
            if (self.naviBar.y - offsetY >= 0) { // 避免出现下拉瞬间超过0
                self.naviBar.y = 0;
            } else {
                self.naviBar.y -= offsetY;
            }
            
        // 更改状态栏状态
        [self changeStatusBarStateWithOffsetY:newOffset.y];
            
        } else { // naviBar消失之后
            // 保持 naviBar 位置不变
            self.naviBar.y = - QDNaviBarMaxY;
            // 更改状态栏状态
            [self changeStatusBarStateWithOffsetY:0];
        }
        
    } else {
        // 更改状态栏状态
        [self changeStatusBarStateWithOffsetY:-QDNaviBarMaxY];
        [self resetNaviBar];
    }
}

- (void)resetNaviBar {
    self.naviBarContentV.transform = CGAffineTransformIdentity;
    
    self.naviBar.y = 0;
    
    self.naviBarContentV.alpha = 1.0;
}

#pragma mark - 更改状态栏状态
- (void)changeStatusBarStateWithOffsetY: (CGFloat)offsetY {
    // 更改状态栏状态
    if (offsetY >= - QDStatusBarH) {
        _statusBarHidden = YES;
    } else if (offsetY <= -QDNaviBarMaxY) {
        _statusBarHidden = NO;
    }
    // 刷新
    [UIView animateWithDuration:0.25 animations:^{
        [self setNeedsStatusBarAppearanceUpdate];
    }];
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationSlide;
}

- (BOOL)prefersStatusBarHidden {
    return _statusBarHidden;
}

@end
