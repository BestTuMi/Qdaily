//
//  QDMessageViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDMessageViewController.h"
#import "QDRefreshHeader.h"
#import "Masonry.h"
#import "QDCustomNaviBar.h"
#import "QDCommentOnMyViewController.h"
#import "QDNotificationLikeViewController.h"
#import "QDNotificationMyLabViewController.h"

@interface QDMessageViewController () <UIScrollViewDelegate>
/** 标签选项卡栏 */
@property (nonatomic, weak)  UIView *toolBar;
/** 选项卡按钮数组数据 */
@property (nonatomic, copy)  NSArray *tabImages;
/** 选项卡按钮数组 */
@property (nonatomic, strong)  NSMutableArray *tabButtons;
/** 记录选中的按钮 */
@property (nonatomic, weak)  UIButton *selectedButton;
/** 自定义导航条 */
@property (nonatomic, weak)  UIView *naviBar;
/** 即将显示的控制器 */
@property (nonatomic, weak)  UIViewController *willShowVc;
/** scrollView */
@property (nonatomic, weak) UIScrollView *scrollView;
@end

@implementation QDMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = QDLightGrayColor;
    
    [self setupChildViewControllers];
    
    [self setupScrollView];
    
    [self setupNavi];
    
    [self setupToolBar];
    
}

#pragma mark - lazyLoad
- (NSArray *)tabImages {
    if (!_tabImages) {
        _tabImages = @[@"Comment_Normal", @"Liked_Normal", @"Join_Normal"];
    }
    return _tabImages;
}

- (NSMutableArray *)tabButtons {
    if (!_tabButtons) {
        _tabButtons = [NSMutableArray array];
    }
    return _tabButtons;
}

#pragma mark - 设置子控件
- (void)setupNavi {
    QDCustomNaviBar *naviBar = [QDCustomNaviBar naviBarWithTitle:@"我的消息"];
    [self.view addSubview:naviBar];
}

- (void)setupChildViewControllers {
     // 评论控制器
    QDCommentOnMyViewController *commentOnMyVc = [[QDCommentOnMyViewController alloc] init];
    [self addChildViewController:commentOnMyVc];

     // 收到的赞
    QDNotificationLikeViewController *notificationLikeVc = [[QDNotificationLikeViewController alloc] init];
    [self addChildViewController:notificationLikeVc];
    
    // 我加入的实验室
    QDNotificationMyLabViewController *notificationLabVc = [[QDNotificationMyLabViewController alloc] init];
    [self addChildViewController:notificationLabVc];
}

- (void)setupScrollView {
    int count = (int)self.childViewControllers.count;
    UIScrollView *rootSc = [[UIScrollView alloc] init];
    rootSc.frame = self.view.bounds;
    rootSc.contentSize = CGSizeMake(count * rootSc.width, rootSc.height);
    rootSc.pagingEnabled = YES;
    rootSc.delegate = self;
    
    // 添加容器视图
    for (int i = 0; i < count; i++) {
        UIView *pageView = [[UIView alloc] init];
        pageView.frame = CGRectMake(i * rootSc.width, 0, rootSc.width, rootSc.height);

        [rootSc addSubview:pageView];
    }
    
    [self.view addSubview:rootSc];
    _scrollView = rootSc;

}

- (void)setupToolBar {
    UIView *toolBar = [[UIView alloc] initWithFrame:CGRectMake(0, QDNaviBarMaxY, QDScreenW, QDToolBarH)];
    // 毛玻璃背景
    [toolBar addBlurViewWithAlpha:0.5];
    // 分割线
    UIView *seprator = [[UIView alloc] initWithFrame:CGRectMake(QDCommonMargin, 0, toolBar.width - QDCommonMargin * 2, 0.5000)];
    seprator.alpha = 0.5;
    [toolBar addSubview:seprator];
    
    [self.view addSubview:toolBar];
    _toolBar = toolBar;
    
    // 添加选项按钮
    int count = (int)self.childViewControllers.count;
    CGFloat buttonX = 0;
    CGFloat buttonY = 0;
    CGFloat buttonW = toolBar.width / count;
    CGFloat buttonH = toolBar.height;
    for (int i = 0; i < self.childViewControllers.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        
        buttonX = buttonW * i;
        
        button.frame = CGRectMake(buttonX, buttonY, buttonW, buttonH);
        [button setImage:self.tabImages[i] selectedImage:[NSString stringWithFormat:@"%@_h", self.tabImages[i]]];
        [toolBar addSubview:button];
        [self.tabButtons addObject:button];
        
        // 添加点击事件
        [button addTarget:self action:@selector(changeTab:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    // 设置默认选中第一页
    [self scrollViewDidEndScrollingAnimation:self.scrollView];
}

- (void)changeTab: (UIButton *)button {
    
    self.selectedButton.enabled = !self.selectedButton.enabled;
    button.enabled = NO;
    
    // 根据 tag 更改 offset, 切换页面
    int pageNumber = (int)[self.tabButtons indexOfObject:button];
    CGPoint offset = self.scrollView.contentOffset;
    offset.x = pageNumber * self.scrollView.width;
    [self.scrollView setContentOffset:offset animated:YES];
    
    self.selectedButton = button;
}

#pragma mark - scrollView delegate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    // 在此懒加载视图
    // 根据 offset 值取出将要显示的控制器
    
    CGFloat offsetX = scrollView.contentOffset.x;
    int pageNumber = offsetX / scrollView.width;
    
    self.willShowVc = self.childViewControllers[pageNumber];
    
    if (self.willShowVc.isViewLoaded) { // 视图加载过
        return;
    } else {
        // 设置 frame 并 加载视图
        self.willShowVc.view.frame = scrollView.bounds;
        [self.scrollView addSubview:self.willShowVc.view];
    }
    
    // 切换 button
    [self changeTab:self.tabButtons[pageNumber]];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self scrollViewDidEndScrollingAnimation:scrollView];
    // 手动切换选项卡
    CGFloat offsetX = scrollView.contentOffset.x;
    int pageNumber = offsetX / scrollView.width;

    [self changeTab:self.tabButtons[pageNumber]];
}

@end
