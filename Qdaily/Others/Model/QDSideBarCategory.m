//
//  QDSideMenuCategory.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarCategory.h"
#import "QDCategoryFeedViewController.h"

@implementation QDSideBarCategory

- (Class)destVcClass {
    // 默认目标控制器为信息流控制器
    return _destVcClass ? _destVcClass : [QDCategoryFeedViewController class];
}

@end
