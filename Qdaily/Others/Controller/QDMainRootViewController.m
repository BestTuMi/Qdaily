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

// 第三方框架
#import <AFNetworking.h>
#import <MJRefresh.h>
#import <MJExtension.h>

#define SideBarKeyPath @"frame"

@interface QDMainRootViewController () <UIGestureRecognizerDelegate, UITableViewDataSource, UITableViewDelegate>
/** 侧边菜单视图 */
@property (nonatomic, weak)  UIView *sideBar;
/** 中间主视图 */
@property (nonatomic, weak) UIView *mainView;
/** 侧边菜单按钮 */
@property (nonatomic, weak)  UIButton *sideBarButton;
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
}

- (void)dealloc {
    // 移除监听
    [self.sideBar removeObserver:self forKeyPath:SideBarKeyPath];
}

#pragma mark - lazyload
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

#pragma mark - 设置 tableView
- (void)setupSideBarTableView {
    UITableView *sideBarTableView = [[UITableView alloc] initWithFrame:_sideBar.bounds style:UITableViewStylePlain];
    [self.sideBar addSubview:sideBarTableView];
    self.sideBarTableView = sideBarTableView;
    
    // 设置相关属性
    sideBarTableView.contentInset = UIEdgeInsetsMake(64, 0, 0, 0);
    sideBarTableView.showsHorizontalScrollIndicator = NO;
    sideBarTableView.showsVerticalScrollIndicator = NO;
    sideBarTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    sideBarTableView.rowHeight = 55;
    
    // 背景色透明
    sideBarTableView.backgroundColor = [UIColor clearColor];
    
    // 添加 Footer
    QDSideBarFooterView *footer = [QDSideBarFooterView viewWithXib];
    self.sideBarTableView.tableFooterView.height = footer.height;
    self.sideBarTableView.tableFooterView = footer;
    
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
    UIButton *sideBarButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    
    sideBarButton.x = 15;
    sideBarButton.width = 37;
    sideBarButton.height = 37;
    sideBarButton.y = QDScreenH - 15 - sideBarButton.height;
    
    // 添加点击事件
    [sideBarButton addTarget:self action:@selector(sideBarButttonClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:sideBarButton];
    _sideBarButton = sideBarButton;
}

#pragma mark - 添加主视图上的子控制器
- (void)setMainViewChildVc:(UIViewController *)mainViewChildVc {
    _mainViewChildVc = mainViewChildVc;
    // 设置 Frame
    mainViewChildVc.view.frame = self.mainView.bounds;
    [self.mainView addSubview:mainViewChildVc.view];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGFloat new = [change[NSKeyValueChangeNewKey] CGRectValue].origin.x;
    CGFloat old = [change[NSKeyValueChangeOldKey] CGRectValue].origin.x;
    CGFloat offsetX = new - old;

    self.sideBarButton.x += offsetX;
}

#pragma mark - 显示隐藏左侧菜单
- (void)sideBarButttonClick {
    if (self.sideBar.x == 0) {
        [self hideSideBar];
    } else {
        [self showSideBar];
    }
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
    
    // TODO: 增加蒙版
    
    // 复位
    [panGesture setTranslation:CGPointZero inView:panGesture.view];
    
    // 改变菜单的 frame
    [self sideBarFrameWithOffsetX:offsetX panGetsture:panGesture];
    
}

#pragma mark - 计算菜单的 Frame
/*!
 *  @brief   手势滑动时计算侧边菜单的 frame
 *
 *  @param offsetX     手势滑动时的 x 偏移量
 *  @param panGetsture 使用的手势,包括平移和边缘平移滑动
 *
 */
- (void)sideBarFrameWithOffsetX: (CGFloat)offsetX panGetsture: (UIPanGestureRecognizer *)panGetsture {
    CGFloat sideBarMaxX = CGRectGetMaxX(_sideBar.frame);
    if (sideBarMaxX >= _sideBar.width) { // 左边达到边缘后不再改变 Frame
        _sideBar.x = 0;
    } else if (sideBarMaxX <= 0) { // 右侧到达边缘后,也不再改变 frame
        _sideBar.x = - _sideBar.width;
    }
    
#warning 未完成
    // TODO: 完成减速动画
    if (panGetsture.state == UIGestureRecognizerStateEnded || panGetsture.state == UIGestureRecognizerStateCancelled) {
        // 根据手势停止时速度向量判断手势方向
        CGFloat velocityX = [panGetsture velocityInView:panGetsture.view].x;
        
        if (sideBarMaxX >= 44 && velocityX > 0) { // 向右滑动达到一定距离
            // 显示完整菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideBar.x = 0;
            }];
        } else if (sideBarMaxX >= (_sideBar.width - 44) && velocityX < 0) { // 向左滑动距离不足
            // 显示完整菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideBar.x = 0;
            }];
        } else {
            // 隐藏菜单
            [UIView animateWithDuration:0.25 animations:^{
                _sideBar.x = - _sideBar.width;
            }];
        }
    }
}

#pragma mark - tableview数据源

- (void)setupCategories {
    QDSideBarCategory *categoryHome = [[QDSideBarCategory alloc] init];
    categoryHome.title = @"首页";
    categoryHome.image = @"slidebar_cell_home_normal";
    categoryHome.image_highlighted = @"slidebar_cell_home_highlighted";
    categoryHome.destVcClass = [QDHomeViewController class];
    
    QDSideBarCategory *categoryLab = [[QDSideBarCategory alloc] init];
    categoryLab.title = @"好奇心实验室";
    categoryLab.image = @"slidebar_cell_lab_normal";
    categoryLab.image_highlighted = @"slidebar_cell_lab_highlighted";
    categoryLab.destVcClass = [QDHomeViewController class];
    
    QDSideBarCategory *categoryFavourite = [[QDSideBarCategory alloc] init];
    categoryFavourite.title = @"收藏";
    categoryFavourite.image = @"slidebar_cell_fav_normal";
    categoryFavourite.image_highlighted = @"slidebar_cell_fav_highlighted";
    categoryFavourite.destVcClass = [QDFavouriteViewController class];
    
    QDSideBarCategory *categoryMsg = [[QDSideBarCategory alloc] init];
    categoryMsg.title = @"消息";
    categoryMsg.image = @"slidebar_cell_notify_normal";
    categoryMsg.image_highlighted = @"slidebar_cell_notify_highlighted";
    categoryMsg.destVcClass = [QDMessageViewController class];
    
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
    [UIView animateWithDuration:0.25 animations:^{
        self.sideBar.x = - self.sideBar.width;
    }];
    
    // 取出模型
    QDSideBarCategory *category = self.categories[indexPath.row];
    
    // 移除之前的视图
    [self.mainViewChildVc.view removeFromSuperview];
    
    // 添加新的视图
    if (category.destVcClass == [self.categoryFeedVc class]) { // 是信息流界面
        [self setMainViewChildVc:self.categoryFeedVc];
    } else if (category.destVcClass == [self.homeVc class]) { // 切换首页
        [self setMainViewChildVc:self.homeVc];
        
        // 菜单中顺序与首页选项卡一致时有效
        [self.homeVc selectTabAtIndex:indexPath.row];

    } else if (category.destVcClass == [self.favouriteVc class]) { // 切换到收藏
        [self setMainViewChildVc:self.favouriteVc];
    } else if (category.destVcClass == [self.messageVc class]) { // 切换消息页面
        [self setMainViewChildVc:self.messageVc];
    }
}

#pragma mark - 处理状态栏
- (UIViewController *)childViewControllerForStatusBarHidden {
    return self.homeVc;
}


@end
