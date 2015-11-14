//
//  MJExtensionConfig.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "MJExtensionConfig.h"
#import <MJExtension.h>
#import "QDSideBarCategory.h"
#import "QDCategory.h"
#import "QDPost.h"
#import "QDAuthor.h"
#import "QDRadarData.h"
#import "QDFeedArticleModel.h"

@implementation MJExtensionConfig

+ (void)load {
    [QDSideBarCategory setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID" : @"id"};
    }];
    
    [QDCategory setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID" : @"id"};
    }];
    
    [QDPost setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID" : @"id",
                 @"detail" : @"description"
                 };
    }];
    
    [QDAuthor setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"userID" : @"id"
                 };
    }];
    
    [QDRadarData setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"geneID" : @"id"
                 };
    }];
    
    [QDFeedArticleModel setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"Id" : @"id"};
    }];
}

@end
