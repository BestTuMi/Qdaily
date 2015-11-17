//
//  QDWebViewFooterLayout.m
//  Qdaily
//
//  Created by Envy15 on 15/11/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDWebViewFooterLayout.h"

@interface QDWebViewFooterLayout ()
/** attrs */
@property (nonatomic, strong) NSMutableArray *attrs;
@end

@implementation QDWebViewFooterLayout

- (void)prepareLayout {
    [super prepareLayout];
    
    [self.attrs removeAllObjects];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i =0; i < count; i++) {
        UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:i inSection:0]];
        [self.attrs addObject:attribute];
    }
    
    UICollectionViewLayoutAttributes *attribute = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:1]];
    [self.attrs addObject:attribute];
    
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrs;
}

- (CGSize)collectionViewContentSize {
    return CGSizeMake(QDScreenW, CGRectGetMaxY(((UICollectionViewLayoutAttributes *)self.attrs.lastObject).frame));
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes *attr = nil;
    if (indexPath.section == 0) {
        CGFloat attrX = 0;
        CGFloat attrH = 183;
        CGFloat attrY = indexPath.item * attrH;
        CGFloat attrW = QDScreenW;
        attr.frame = CGRectMake(attrX, attrY, attrW, attrH);
    } else if (indexPath.section == 1) {
        attr.frame = CGRectMake(0, 0, QDScreenW, 200);
    }
    return attr;
}

@end
