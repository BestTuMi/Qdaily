//
//  QDHomeViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeViewController.h"

@interface QDHomeViewController ()
/** ScrollView */
@property (nonatomic, weak) UIView *scrollView;
@end

@implementation QDHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupScrollView];
}

#pragma mark - 设置 ScrollView
- (void)setupScrollView {
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = self.view.bounds;
    [self.view addSubview:scrollView];
}

@end
