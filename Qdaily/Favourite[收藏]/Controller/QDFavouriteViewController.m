//
//  QDFavouriteViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFavouriteViewController.h"

#import "QDCustomNaviBar.h"
#import "QDSideBarCategory.h"


@interface QDFavouriteViewController ()

/** 自定义导航条 */
@property (nonatomic, weak)  QDCustomNaviBar *naviBar;

@end

@implementation QDFavouriteViewController

- (NSString *)requestUrl {
    return @"/app/users/praises";
}

- (NSDictionary *)parameters {
    return @{@"last_time" : self.last_time};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupNavi];
    
}

#pragma mark - 设置子控件
- (void)setupNavi {
    QDCustomNaviBar *naviBar = [QDCustomNaviBar naviBarWithTitle:self.category.title];
    [self.view addSubview:naviBar];
    self.naviBar = naviBar;
}

#pragma mark - 设置 ID
- (void)setCategory:(QDSideBarCategory *)category {
    _category = category;
    // 刷洗UI
    self.naviBar.title = category.title;
}

@end
