//
//  QDSideMenuHeaderView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/12.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarHeaderView.h"
#import "Masonry.h"
#import "QDPentagonView.h"
#import "QDLoginViewController.h"
#import "QDNavigationController.h"
#import "QDMainRootViewController.h"
#import "QDUserAccountViewModel.h"
#import "QDUserCenterVM.h"
#import <MJExtension.h>
#import "QDUserCenterModel.h"
#import "QDUserCenterTableViewController.h"
#import <UIImageView+WebCache.h>

@interface QDSideBarHeaderView () <LoginViewControllerDelegate>
@property (weak, nonatomic) IBOutlet QDPentagonView *outerLine;
@property (weak, nonatomic) IBOutlet QDPentagonView *interLine;
@property (weak, nonatomic) IBOutlet QDPentagonView *radarView;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
/** 记录登录状态 */
@property (nonatomic, assign)  BOOL isLogin;
/** 用户中心视图模型 */
@property (nonatomic, strong)  QDUserCenterVM *userCenterVm;
/** 用户中心控制器 */
@property (nonatomic, strong)  QDUserCenterTableViewController *userCenterVc;
@end

@implementation QDSideBarHeaderView

+ (instancetype)viewWithXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib {
   
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    // 登陆按钮
    [self.loginButton setTitle:@"登录" forState: UIControlStateNormal];
    [self.loginButton setTitleColor:QDHighlightColor forState:UIControlStateNormal];
    self.loginButton.adjustsImageWhenHighlighted = NO;
    
    // 为头像增加点击事件
    [self.iconImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login:)]];
    
    [self setupGenes];
    
    [self autoLogin];
}

#pragma mark - lazyload
- (QDUserCenterTableViewController *)userCenterVc {
    if (!_userCenterVc) {
        _userCenterVc = [[QDUserCenterTableViewController alloc] initWithStyle:UITableViewStyleGrouped];
    }
    return _userCenterVc;
}

- (void)setupGenes {
    self.circleView.layer.cornerRadius = self.circleView.width * 0.5;
    self.circleView.layer.borderWidth = 1.0;
    self.circleView.layer.borderColor = [QDHighlightColor colorWithAlphaComponent:0.2].CGColor;
    
    // 设置绘制参数
    self.radarView.genes = @[@(0.54), @(0.54), @(0.54), @(0.54), @(0.54)];
    self.radarView.showType = 2;
    self.radarView.showWidtn = 1.0;
    
    // 设置绘制参数
    self.outerLine.genes = @[@(1.0), @(1.0), @(1.0), @(1.0), @(1.0)];
    self.outerLine.showType = 1; // 黑色半透明填充
    self.outerLine.showColor = QDRGBWhiteColor(0, 0.2);
    
    self.interLine.genes = @[@(1.0), @(1.0), @(1.0), @(1.0), @(1.0)];
    self.interLine.showType = 1; // 黑色半透明填充
    self.interLine.showColor = QDRGBWhiteColor(0, 0.4);
}

- (IBAction)login:(id)sender {
    QDLoginViewController *loginVc = [[QDLoginViewController alloc] init];
    loginVc.delegate = self;
    QDNavigationController *navi = (QDNavigationController *)self.window.rootViewController;
    QDMainRootViewController *mainRootVc = navi.childViewControllers[0];
    
    if (!self.isLogin) { // 没有登录,跳转登录界面
         [mainRootVc presentViewController:[[QDNavigationController alloc] initWithRootViewController:loginVc] animated:YES completion:nil];
    } else { // 更换主界面容器视图为个人中心
        if (![mainRootVc.childViewControllers containsObject:self.userCenterVc]) {
            [mainRootVc addChildViewController:self.userCenterVc];
        }
        [mainRootVc setMainViewChildVc:self.userCenterVc];
        [mainRootVc hideSideBar];
    }
}

// 自动登录
- (void)autoLogin {
    // 判断是否可以使用保存的信息登录
    if ([QDUserAccountViewModel sharedInstance].canLogin) {
        
        // 先禁用按钮点击
        self.loginButton.userInteractionEnabled = NO;
        self.iconImageView.userInteractionEnabled = NO;
        
        QDUserAccountModel *userAccount = [QDUserAccountViewModel sharedInstance].userAccountModel;
        [[QDUserAccountViewModel sharedInstance] login:userAccount finished:^(NSDictionary *responseObject, NSError *error) {
            
            if (error) {
                QDLogVerbose(@"%@", error);
                
                // 保存登录状态
                self.isLogin = NO;
                
                // 刷新 UI
                [self refreshUI];
                
                return;
            }
            
            // 设置模型
            self.userCenterVm = [QDUserCenterVM sharedInstance];
            self.userCenterVm.userCenterModel = [QDUserCenterModel mj_objectWithKeyValues:responseObject[@"response"]];
            
            // 保存登录状态
            self.isLogin = YES;
            
            // 刷新 UI
            [self refreshUI];
            
        }];
    }
}

- (void)refreshUI {
    
    if (self.isLogin) { // 登录成功
        // 恢复点击
        self.loginButton.userInteractionEnabled = YES;
        self.iconImageView.userInteractionEnabled = YES;
        
        // 更改登录按钮的状态
        [self.loginButton setTitle:self.userCenterVm.userCenterModel.username forState:UIControlStateNormal];
        [self.loginButton setTitleColor:QDLightGrayColor forState:UIControlStateNormal];
        
        // 更新用户头像
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:self.userCenterVm.userCenterModel.face] completed:nil];
        
    } else { // 登录失败
        // 恢复点击
        self.loginButton.userInteractionEnabled = YES;
        self.iconImageView.userInteractionEnabled = YES;
        
        // 更改登录按钮的状态
        [self.loginButton setTitle:@"登录" forState:UIControlStateNormal];
        [self.loginButton setTitleColor: QDHighlightColor forState:UIControlStateNormal];
        
        // 更新用户头像
        self.iconImageView.image = [UIImage imageNamed:@"defult_userIcon_palcehold"];
        
    }
    
    // 更新个人 五边形属性视图(地址错误时,就不会更新用户 gene, 也就是使用初始化默认值)
    [self.userCenterVm loadGenesData:^(NSDictionary *responseObject, NSError *error) {
        // 验证数据
        if (error) {
            return;
        }
        self.radarView.genes = [self.userCenterVm.userCenterModel.genes valueForKeyPath:@"value"];
    }];
}

#pragma mark - loginVc delegate
- (void)loginViewControllerDidLogin:(QDLoginViewController *)loginVc {
    [self autoLogin];
}

@end
