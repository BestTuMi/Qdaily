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
@property (weak, nonatomic) IBOutlet UIButton *weiboBtn;    ///< weibo按钮
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;     ///< 取消按钮
@end

@implementation QDLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    void(^doNext)(QDUserAccountModel *) = ^(QDUserAccountModel *userAccount){
        @strongify(self);
        // 发起登录请求 (在回到前台的时候才调用)
        [[QDUserAccountViewModel sharedInstance] login:userAccount finished:^(NSDictionary *responseObject, NSError *error) {
            // 验证数据
            if (error) {
                QDLogVerbose(@"%@", error);
                return;
            }
            [self dismissViewControllerAnimated:YES completion:nil];
            if ([self.delegate respondsToSelector:@selector(loginViewControllerDidLogin:)]) {
                [self.delegate loginViewControllerDidLogin:self];
            }
            QDLogVerbose(@"%@", responseObject[@"response"]);
        }];
    };
    
    _weiboBtn.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
        return [[[[QDUserAccountViewModel sharedInstance] weiboLoginWithViewController:self]
                 doNext:doNext]
                catch:^RACSignal *(NSError *error) {
                    [MBProgressHUD showError:error.localizedDescription];
                    return [RACSignal empty];
                }];
    }];
    
    [[_cancelButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
