//
//  QDQTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeFeedArticleViewController.h"

@interface QDHomeFeedArticleViewController ()

@end

@implementation QDHomeFeedArticleViewController

static NSString * const reuseIdentifier = @"Cell";


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = QDRandomColor;
//    [self setupCollectionView];
}

//- (void)setupCollectionView {
//    UICollectionViewLayout *
//    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:layout];
//    // 设置内边距
//    self.collectionView.contentInset = UIEdgeInsetsMake(QDNaviBarMaxY, 0, 0, 0);
//    self.collectionView.backgroundColor = QDRandomColor;
//}

@end
