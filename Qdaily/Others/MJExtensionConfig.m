//
//  MJExtensionConfig.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "MJExtensionConfig.h"
#import <MJExtension.h>
#import "QDSideMenuCategory.h"

@implementation MJExtensionConfig

+ (void)load {
    [QDSideMenuCategory setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID" : @"id"};
    }];
}

@end
