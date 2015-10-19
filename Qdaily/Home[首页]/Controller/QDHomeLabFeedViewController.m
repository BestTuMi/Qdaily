//
//  QDLabTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeLabFeedViewController.h"

@interface QDHomeLabFeedViewController ()

@end

@implementation QDHomeLabFeedViewController

static NSString * const paperIdentifier = @"feedPaperCell";

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSString *)requestUrl {
    return @"app/papers/index/";
}

@end
