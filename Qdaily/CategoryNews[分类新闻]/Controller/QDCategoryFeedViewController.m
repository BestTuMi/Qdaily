//
//  QDCategoryFeedViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCategoryFeedViewController.h"
#import "QDCollectionView.h"
#import "QDCustomNaviBar.h"

@interface QDCategoryFeedViewController ()
/** 自定义导航条 */
@property (nonatomic, weak)  QDCustomNaviBar *naviBar;
@end

@implementation QDCategoryFeedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
     [self setupNavi];
}

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/categories/index/%@/", self.ID] ;
}

#pragma mark - 设置子控件
- (void)setupNavi {
    QDCustomNaviBar *naviBar = [QDCustomNaviBar naviBarWithTitle:self.categoryTitle];
    [self.view addSubview:naviBar];
}

- (void)setCategoryTitle:(NSString *)categoryTitle {
    _categoryTitle = categoryTitle;
    self.naviBar.title = categoryTitle;
}
@end
