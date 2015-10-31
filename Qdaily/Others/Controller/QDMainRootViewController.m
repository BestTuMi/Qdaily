//
//  QDMainRootViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDMainRootViewController.h"
#import "QDNavigationController.h"

// 目录
#import "QDHomeViewController.h"
#import "QDHomeFeedArticleViewController.h"
#import "QDHomeLabFeedViewController.h"
#import "QDMessageViewController.h"
#import "QDFavouriteViewController.h"
#import "QDCategoryFeedViewController.h"

#import "QDSideBarCategory.h"
#import "QDSideBarCell.h"
#import "QDSideBarFooterView.h"
#import "QDSideBarHeaderView.h"

#import "QDAnimateButton.h"

// 新手引导
#import "QDMainUserGuideView.h"
#import "QDSideBarUserGuideView.h"

// 第三方框架
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>
#import <POP.h>

#define SideBarKeyPath @"frame"

@interface QDMainRootViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
/** 侧边菜单视图 */
@property (nonatomic, weak)  UIView *sideBar;
/** 中间主视图 */
@property (nonatomic, weak) UIView *mainView;
/** 蒙版层 */
@property (nonatomic, strong) UIView *maskView;
/** 侧边菜单按钮 */
@property (nonatomic, weak)  QDAnimateButton *sideBarButton;
/** 菜单是否在屏幕上 */
@property (nonatomic, assign) BOOL isSideBarVisibele;
/** 当前添加到主视图上的 控制器 */
@property (nonatomic, weak) UIViewController *mainViewChildVc;
/** 主页控制器 */
@property (nonatomic, strong) QDHomeViewController *homeVc;
/** 消息控制器 */
@property (nonatomic, strong)  QDMessageViewController *messageVc;
/** 收藏控制器 */
@property (nonatomic, strong)  QDFavouriteViewController *favouriteVc;
/** 信息流控制器 */
@property (nonatomic, strong)  QDCategoryFeedViewController *categoryFeedVc;

/*********** tableView相关 **********/
/** 目录模型数组 */
@property (nonatomic, strong)  NSMutableArray *categories;
/** 侧边的 tableView */
@property (nonatomic, weak) UITableView *sideBarTableView;
/** AFN 管理者 */
@property (nonatomic, strong)  AFHTTPSessionManager *manager;
@end

@implementation QDMainRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    [self setupMainView];
    [self setupsideBar];
    // 侧边按钮如果跟菜单在同一 View 会影响边缘手势范围.因此独立出来
    [self setupSideBarButton];
    
    // 添加监听
    [self addObservers];
}

#pragma mark - 判断是否显示新手引导
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (QDShouldShowMainUserGuide) {
        // 需要显示新手引导
        [QDMainUserGuideView show];
    }
}

- (void)dealloc {
    // 移除监听
    [self.sideBar removeObserver:self forKeyPath:SideBarKeyPath];
}

#pragma mark - lazyload
- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _maskView.backgroundColor = QDRGBWhiteColor(0, 1.0);
        _maskView.alpha = 0.0;
        
        // 添加手势
        // 使用主视图控制器的 target
        UIPanGestureRecognizer *maskPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
        [_maskView addGestureRecognizer:maskPan];
        
        // 额外增加一个点击手势,直接收起菜单
        UITapGestureRecognizer *maskTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideSideBar)];
        [_maskView addGestureRecognizer:maskTap];
    }
    return _maskView;
}

- (QDHomeViewController *)homeVc {
    if (!_homeVc) {
        _homeVc = [[QDHomeViewController alloc] init];
        [self addChildViewController:_homeVc];
    }
    return _homeVc;
}

- (QDMessageViewController *)messageVc {
    if (!_messageVc) {
        _messageVc = [[QDMessageViewController alloc] init];
        [self addChildViewController:_messageVc];
    }
    return _messageVc;
}

- (QDFavouriteViewController *)favouriteVc {
    if (!_favouriteVc) {
        _favouriteVc = [[QDFavouriteViewController alloc] init];
        [self addChildViewController:_favouriteVc];
    }
    return _favouriteVc;
}

- (QDCategoryFeedViewController *)categoryFeedVc {
    if (!_categoryFeedVc) {
        _categoryFeedVc = [[QDCategoryFeedViewController alloc] init];
        [self addChildViewController:_categoryFeedVc];
    }
    return _categoryFeedVc;
}

// 目录模型数组
- (NSMutableArray *)categories {
    if (!_categories) {
        _categories = [NSMutableArray array];
    }
    return _categories;
}

#pragma mark - AFN 管理者懒加载
- (AFHTTPSessionManager *)manager {
    if (!_manager) {
        _manager = [[AFHTTPSessionManager alloc] initWithBaseURL:QDBaseURL];
    }
    return _manager;
}

#pragma mark - 设置导航条
- (void)setupNavi {
    self.navigationController.navigationBarHidden = YES;
}

#pragma mark - 设置主视图
- (void)setupMainView {
    // 取消自动内边距
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    UIView *mainView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];

    // 添加边缘滑动手势
    UIScreenEdgePanGestureRecognizer *edgePanGesture = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    // 滑动范围为左侧
    edgePanGesture.edges = UIRectEdgeLeft;
    [mainView addGestureRecognizer:edgePanGesture];
    
    // 设置手势代理
    edgePanGesture.delegate = self;

    [self.view addSubview:mainView];
    _mainView = mainView;
}

#pragma mark - 设置左侧菜单视图
- (void)setupsideBar {
    UIView *sideBar = [[UIView alloc] init];
    
    // 宽度为屏幕宽的80%
    CGFloat sideBarViewW = QDScreenW * 0.8;
    CGFloat sideBarViewX = - sideBarViewW;
    sideBar.frame = CGRectMake(sideBarViewX, 0, sideBarViewW, QDScreenH);
    
    // 背景现设为透明,方便透出背景
    sideBar.backgroundColor = [UIColor clearColor];
    
    // 添加模糊特效层
    [sideBar addBlurViewWithAlpha:0.8];
    
    // 使用 KVO 监听左侧菜单 Frame 变化,并改变菜单按钮 Frame 和其他值
    [sideBar addObserver:self forKeyPath:SideBarKeyPath options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    
    // 添加滑动手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
    [sideBar addGestureRecognizer:panGesture];
    
    [self.view addSubview:sideBar];

    _sideBar = sideBar;
    
    // 设置tableView(添加为 子控件)
    [self setupSideBarTableView];
}

#pragma mark - 设置左侧 tableView
- (void)setupSideBarTableView {
    UITableView *sideBarTableView = [[UITableView alloc] initWithFrame:_sideBar.bounds style:UITableViewStylePlain];
    [self.sideBar addSubview:sideBarTableView];
    self.sideBarTableView = sideBarTableView;
    
    
    // 添加 header
    QDSideBarHeaderView *header = [QDSideBarHeaderView viewWithXib];
    header.height = 273;
    header.width = sideBarTableView.width;
    header.y = - header.height;
    [self.sideBarTableView addSubview:header];
    
    // 添加 Footer
    QDSideBarFooterView *footer = [QDSideBarFooterView viewWithXib];
    self.sideBarTableView.tableFooterView.height = footer.height;
    self.sideBarTableView.tableFooterView = footer;
    
    // 设置相关属性
    sideBarTableView.contentInset = UIEdgeInsetsMake(header.height, 0, 0, 0);
    sideBarTableView.showsHorizontalScrollIndicator = NO;
    sideBarTableView.showsVerticalScrollIndicator = NO;
    sideBarTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    sideBarTableView.rowHeight = 55;
    
    // 背景色透明
    sideBarTableView.backgroundColor = [UIColor clearColor];

    // tableView 的代理和数据源
    sideBarTableView.dataSource = self;
    sideBarTableView.delegate = self;
    // 设置数据源
    [self setupCategories];
    
    // 默认选中首页(懒加载首页视图)
    [self tableView:self.sideBarTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
}

#pragma mark - 侧边菜单按钮
- (void)setupSideBarButton {

    QDAnimateButton *sideBarButton = [QDAnimateButton buttonWithOrigin:CGPointMake(15, QDScreenH - 60)];
    sideBarButton.tintColor = QDRGBWhiteColor(1.0, 1.0);
    [sideBarButton addTarget:self action:@selector(sideBarButttonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sideBarButton];
    _sideBarButton = sideBarButton;
}

#pragma mark - 改变主视图上的子控制器视图
- (void)setMainViewChildVc:(UIViewController *)mainViewChildVc {
    _mainViewChildVc = mainViewChildVc;
    // 设置 Frame
    mainViewChildVc.view.frame = self.mainView.bounds;
    
    // 移除之前的 view, 添加新的
    for (UIView *view in self.mainView.subviews) {
        [view removeFromSuperview];
    }
    
    [self.mainView addSubview:mainViewChildVc.view];
}

#pragma mark - 添加必要的监听
- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showSideBar) name:QDShowSideBarNNotification object:nil];
}

#pragma mark - 移除监听
- (void)removeObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    // 监听 sideBar 的位置改变
    CGFloat new = [change[NSKeyValueChangeNewKey] CGRectValue].origin.x;
    CGFloat old = [change[NSKeyValueChangeOldKey] CGRectValue].origin.x;
    CGFloat offsetX = new - old;

    self.sideBarButton.x += offsetX;
    
    if (new == 0) { // 完全显示出来
        if (QDShouldShowSideBarUserGuide) {
            // 需要显示 sideBar 的新手引导
            [QDSideBarUserGuideView show];
        }
    }
    
    // 设置蒙版透明度
    [self setMaskViewAlpha];
}

#pragma mark - 显示隐藏左侧菜单
- (void)sideBarButttonClick {
    if (self.sideBar.x == 0) {
        [self hideSideBar];
    } else {
        [self showSideBar];
    }
    // 内部动画
    BOOL showMenu = !(self.sideBar.x == 0);
    [self.sideBarButton touchUpInsideHandler:showMenu];
}

- (void)showSideBar {
    [UIView animateWithDuration:0.25 animations:^{
        self.sideBar.x = 0;
    }];
}

- (void)hideSideBar {
    [UIView animateWithDuration:0.25 animations:^{
        self.sideBar.x = - self.sideBar.width;
    }];
}

#pragma mark - 滑动显示左侧菜单
- (void)pan: (UIPanGestureRecognizer *)panGesture {
    // 获取偏移值(在手势所在的视图)
    CGPoint offsetP = [panGesture translationInView:panGesture.view];
    CGFloat offsetX = offsetP.x;
    
    // 改变菜单 frame
    _sideBar.x += offsetX;
    
    // 添加蒙版层
    [self.mainView addSubview:self.maskView];
    
    // 复位
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    
    // 改变菜单的 frame并改变蒙版的 alpha
    [self sideBarFrameWithPanGetsture:panGesture];
    
}

#pragma mark - 设置蒙版层透明度
- (void)setMaskViewAlpha {
    // Alpha 最终值为0.6
    self.maskView.alpha = CGRectGetMaxX(self.sideBar.frame) / self.sideBar.width * 0.6 >= 0.6 ? 0.6 : CGRectGetMaxX(self.sideBar.frame) / self.sideBar.width * 0.6;
}

#pragma mark - 计算菜单的 Frame
/*!
 *  @brief   手势滑动时计算侧边菜单的 frame
 *
 *  @param panGetsture 使用的手势,包括平移和边缘平移滑动
 *
 */
- (void)sideBarFrameWithPanGetsture: (UIPanGestureRecognizer *)panGetsture {
    CGFloat sideBarMaxX = CGRectGetMaxX(_sideBar.frame);
    if (sideBarMaxX >= _sideBar.width) { // 左边达到边缘后不再改变 Frame
        _sideBar.x = 0;
    } else if (sideBarMaxX <= 0) { // 右侧到达边缘后,也不再改变 frame
        _sideBar.x = - _sideBar.width;
    }
    
    // TODO:减速动画
    if (panGetsture.state == UIGestureRecognizerStateEnded || panGetsture.state == UIGestureRecognizerStateCancelled) {
        // 动画时间
        CGFloat duration = 0.1;
        
        // 根据手势停止时速度向量判断手势方向
        CGFloat velocityX = [panGetsture velocityInView:panGetsture.view].x;
        
        if (sideBarMaxX >= 44 && velocityX > 0) { // 向右滑动达到一定距离
            // 显示完整菜单
            [UIView animateWithDuration:duration animations:^{
                _sideBar.x = 0;
            }];
        } else if (sideBarMaxX >= (_sideBar.width - 44) && velocityX < 0) { // 向左滑动距离不足
            // 显示完整菜单
            [UIView animateWithDuration:duration animations:^{
                _sideBar.x = 0;
            }];
        } else if (sideBarMaxX < 44 && velocityX > 0){ // 向右滑动距离不足
            [UIView animateWithDuration:duration animations:^{
                _sideBar.x = - _sideBar.width;
            }];
        } else {
            // 隐藏菜单
            [UIView animateWithDuration:duration animations:^{
                _sideBar.x = - _sideBar.width;
            }];
        }
        
         // 处理按钮内部动画
        BOOL showMenu = !(self.sideBar.x == 0);
        [self.sideBarButton touchUpInsideHandler: showMenu];
    }
}

#pragma mark - tableview数据源

- (void)setupCategories {
    QDSideBarCategory *categoryHome = [QDSideBarCategory categoryWithImage:@"slidebar_cell_home_normal"
                                                               destVcClass:[QDHomeViewController class]
                                                                     Title:@"首页"];
    
    
    QDSideBarCategory *categoryLab = [QDSideBarCategory categoryWithImage:@"slidebar_cell_lab_normal"
                                                              destVcClass:[QDHomeViewController class]
                                                                    Title:@"好奇心实验室"];
    
    QDSideBarCategory *categoryFavourite = [QDSideBarCategory categoryWithImage:@"slidebar_cell_fav_normal"
                                                                    destVcClass:[QDFavouriteViewController class]
                                                                          Title:@"收藏"];
    
    QDSideBarCategory *categoryMsg = [QDSideBarCategory categoryWithImage:@"slidebar_cell_notify_normal"
                                                              destVcClass:[QDMessageViewController class]
                                                                    Title:@"消息"];
    
    [self.categories addObjectsFromArray:@[categoryHome, categoryLab, categoryFavourite, categoryMsg]];
    
    // 剩下的从网络抓取
    [self.manager GET:@"app/homes/left_sidebar.json?" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        // 字典转模型
        NSArray *categories = [QDSideBarCategory objectArrayWithKeyValuesArray:responseObject[@"response"]];
        [self.categories addObjectsFromArray:categories];
        // 刷新表格
        [self.sideBarTableView reloadData];

        // 更改默认选中菜单的状态
        [self.sideBarTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
    }];
}

#pragma mark - 设置状态栏颜色
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const identifier = @"sideBarCell";
    QDSideBarCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell  = [[QDSideBarCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    // 取模型
    QDSideBarCategory *category = self.categories[indexPath.row];
    cell.category = category;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // 隐藏菜单
    [self hideSideBar];
    
    // 处理按钮内部动画
    [self.sideBarButton touchUpInsideHandler:YES];
    
    // 取出模型
    QDSideBarCategory *category = self.categories[indexPath.row];
    
    // 添加新的视图
    if (category.destVcClass == [self.categoryFeedVc class]) { // 是信息流界面
        // 注意view 在这一步加载
        [self setMainViewChildVc:self.categoryFeedVc];
        self.categoryFeedVc.category = category;
        
    } else if (category.destVcClass == [self.homeVc class]) { // 切换首页
        [self setMainViewChildVc:self.homeVc];
        
        // 菜单中顺序与首页选项卡一致时有效
        [self.homeVc selectTabAtIndex:indexPath.row];

    } else if (category.destVcClass == [self.favouriteVc class]) { // 切换到收藏
        [self setMainViewChildVc:self.favouriteVc];
        self.favouriteVc.category = category;
    } else if (category.destVcClass == [self.messageVc class]) { // 切换消息页面
        [self setMainViewChildVc:self.messageVc];
    }
}

#pragma mark - 处理状态栏
- (UIViewController *)childViewControllerForStatusBarHidden {
    // 判断首页的是否在窗口上显示
    // 如果在窗口上,状态栏交给它管理
    if (self.homeVc.view.window) {
        return self.homeVc;
    }
    return [super childViewControllerForStatusBarHidden];
}

@end
