//
//  QDQTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeFeedArticleViewController.h"
#import "QDCollectionView.h"

@interface QDHomeFeedArticleViewController ()

@end

@implementation QDHomeFeedArticleViewController

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/homes/index/%@.json?", self.last_time];
}

@end
