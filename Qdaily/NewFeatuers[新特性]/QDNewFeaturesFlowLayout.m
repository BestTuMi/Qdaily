//
//  QDNewFeaturesFlowLayout.m
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//
#import "QDNewFeaturesFlowLayout.h"

@interface QDNewFeaturesFlowLayout ()
/** layout 数组 */
@property (nonatomic, strong) NSMutableArray *attrs;
@end

@implementation QDNewFeaturesFlowLayout


- (NSMutableArray *)attrs {
    if (!_attrs) {
        _attrs = [NSMutableArray array];
    }
    return _attrs;
}

- (void)prepareLayout {
    [super prepareLayout];
    // 每次进来先移除之前的
    [self.attrs removeAllObjects];
    
    int count = (int)[self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        UICollectionViewLayoutAttributes *attr = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        CGFloat itemY = 0;
        CGFloat itemW = QDScreenW;
        CGFloat itemH = QDScreenH;
        CGFloat itemX = QDScreenW * i;
        attr.frame = CGRectMake(itemX, itemY, itemW, itemH);
        [self.attrs addObject:attr];
    }
    
    self.minimumLineSpacing = 0;
    self.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.bounces = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrs;
}

- (CGSize)collectionViewContentSize {
    int count = (int)[self.collectionView numberOfItemsInSection:0];
    return CGSizeMake(QDScreenW * count, QDScreenH);
}

@end
