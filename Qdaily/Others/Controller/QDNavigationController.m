//
//  QDNavigationController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNavigationController.h"
#import "QDNavigationBar.h"

@interface QDNavigationController ()

@end

@implementation QDNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 替换原有的导航条
    QDNavigationBar *naviBar = [[QDNavigationBar alloc] init];
    [self setValue:naviBar forKeyPath:@"navigationBar"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
