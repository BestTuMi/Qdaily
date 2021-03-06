//
//  QDSideMenuFooterView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/12.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarFooterView.h"
#import "QDSearchViewController.h"
#import "QDMainRootViewController.h"
#import "QDNavigationController.h"

@interface QDSideBarFooterView ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepratorAtOffineCos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepratorAtSettingCos;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *sepratorHeaderCos;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
/** 所属控制器 */
@property (nonatomic, weak) QDMainRootViewController *mainRootViewController;
@end

@implementation QDSideBarFooterView

+ (instancetype)viewWithXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].firstObject;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    // 设置分割线
    self.sepratorAtOffineCos.constant = 0.5;
    self.sepratorAtSettingCos.constant = 0.5;
    self.sepratorHeaderCos.constant = 0.5;
    
    @weakify(self);
    [[_searchButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        QDSearchViewController *searchVc = [[QDSearchViewController alloc] init];
        QDNavigationController *navi = [[QDNavigationController alloc] initWithRootViewController:searchVc];
        [self.mainRootViewController presentViewController:navi animated:YES completion:nil];
        // 隐藏侧边栏
        [self.mainRootViewController hideSideBar];
    }];
}

- (void)didMoveToWindow {
    // 取出 mainRootViewController,方便后续调用
    _mainRootViewController = ((QDNavigationController *)(self.window.rootViewController)).childViewControllers[0];
}

@end


@implementation QDSideBarButton

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.x = 5;
    self.imageView.centerY = self.height * 0.5;
}

@end
