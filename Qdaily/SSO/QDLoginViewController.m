//
//  QDLoginViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/26.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDLoginViewController.h"
#import "QDUserAccountViewModel.h"
#import "MBProgressHUD+Message.h"
#import "QDUserAccountModel.h"

@interface QDLoginViewController ()

@end

@implementation QDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 检查登录状态
    if ([QDUserAccountViewModel sharedInstance]) {
        
    }
}

- (IBAction)weiboLogin:(id)sender {
    QDWeakSelf;
    [[QDUserAccountViewModel sharedInstance] weiboLoginWithViewController:weakSelf finished:^(QDUserAccountModel *userAccount, NSError *error) {
        // 验证数据
        if (error) {
            [MBProgressHUD showError:error.userInfo[@"msg"]];
            return;
        }
        
        // 发起登录请求 (在回到前台的时候才调用)
        [[QDUserAccountViewModel sharedInstance] login:userAccount finished:^(NSDictionary *responseObject, NSError *error) {
            // 验证数据
            if (error) {
                QDLogVerbose(@"%@", error);
            }
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            QDLogVerbose(@"%@", responseObject[@"response"]);
        }];
    }];
}

@end
