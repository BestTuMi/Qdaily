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

// 便利构造方法
+ (instancetype)categoryWithImage: (NSString *)image destVcClass: (Class)destVcClass Title: (NSString *)title {
    return [[self alloc] initWithImage:image destVcClass:destVcClass Title:title];
}

- (instancetype)initWithImage: (NSString *)image destVcClass: (Class)destVcClass Title: (NSString *)title {
    if (self = [super init]) {
        self.title = title;
        self.image = image;
        self.image_highlighted = [image stringByReplacingOccurrencesOfString:@"normal" withString:@"highlighted"];
        self.destVcClass = destVcClass;
    }
    return self;
}

- (Class)destVcClass {
    // 默认目标控制器为信息流控制器
    return _destVcClass ? _destVcClass : [QDCategoryFeedViewController class];
}

@end
