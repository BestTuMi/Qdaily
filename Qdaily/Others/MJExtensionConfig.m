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
#import "QDChildComment.h"
#import "QDComment.h"

@implementation MJExtensionConfig

+ (void)load {
    [QDSideBarCategory mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID" : @"id"};
    }];
    
    [QDCategory mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"ID" : @"id"};
    }];
    
    [QDPost mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"ID" : @"id",
                 @"detail" : @"description"
                 };
    }];
    
    [QDAuthor mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"userID" : @"id"
                 };
    }];
    
    [QDRadarData mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"geneID" : @"id"
                 };
    }];
    
    [QDFeedArticleModel mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{@"Id" : @"id"};
    }];
    
    [QDComment mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"Id" : @"id",
                 };
    }];
    
    [QDComment mj_setupObjectClassInArray:^NSDictionary *{
        return @{
                 @"child_comments" : @"QDChildComment"
                 };
    }];
    
    [QDChildComment mj_setupReplacedKeyFromPropertyName:^NSDictionary *{
        return @{
                 @"Id" : @"id"
                 };
    }];
}

@end
