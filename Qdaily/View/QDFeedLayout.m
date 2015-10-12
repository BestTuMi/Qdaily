//
//  QDFeedLayout.m
//  Qdaily
//
//  Created by Envy15 on 15/10/11.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedLayout.h"
#import "QDFeed.h"

@interface QDFeedLayout ()
/** layoutAttributes */
@property (nonatomic, strong) NSMutableArray *attrsArray;
@end

@implementation QDFeedLayout

#pragma mark - lazyload
- (NSMutableArray *)attrsArray {
    if (!_attrsArray) {
        _attrsArray = [NSMutableArray array];
    }
    return _attrsArray;
}

#pragma mark -
#pragma mark - 初始化布局
- (void)prepareLayout {
    [super prepareLayout];
    
    [self.attrsArray removeAllObjects];
    
    NSInteger count = [self.collectionView numberOfItemsInSection:0];
    for (int i = 0; i < count; i++) {
        // 创建UICollectionViewLayoutAttributes
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        // 设置布局属性
        
        // 获取当前位置的模型,并根据类型属性判断应该返回什么样的 Cell
        QDFeed *feed = self.feeds[i];
        QDFeed *previousFeed = (i == 0 || i == 1 ) ? nil : self.feeds[i - 1];
        
        int numberOfItemsPerRow = 4;
        CGFloat feedMargin = 3;
        CGFloat itemX = 0;
        CGFloat itemY = 0;
        CGFloat itemW = QDScreenW;
        CGFloat itemH = itemW * 173 / 320;
        
        if (i != 0) {

            if (feed.type == QDFeedCellTypeSmall) { // 类型是小图
                itemW = (QDScreenW - feedMargin * (numberOfItemsPerRow - 1)) / numberOfItemsPerRow;
                itemH = itemW * 195 / 158.5;
                // 获取最后一个attrs
                UICollectionViewLayoutAttributes *lastAttrs = self.attrsArray[i - 1];
                // 计算右边剩余空间
                CGFloat leftMaxX = CGRectGetMaxX(lastAttrs.frame) + feedMargin;
                CGFloat rightSpace = QDScreenW - leftMaxX;
                if (rightSpace >= itemW) { // 不用换行
                    itemX = leftMaxX;
                    itemY = lastAttrs.frame.origin.y;
                } else {
                    itemX = 0;
                    itemY = CGRectGetMaxY(lastAttrs.frame);
                    if (previousFeed.type != QDFeedCellTypeSmall) {
                        itemY += feedMargin;
                    }
                }
            } else { // 大图
                
                UICollectionViewLayoutAttributes *lastAttrs = self.attrsArray[i - 1];
                itemY = CGRectGetMaxY(lastAttrs.frame) + feedMargin;

                // 计算右边剩余空间
                CGFloat leftMaxX = CGRectGetMaxX(lastAttrs.frame) + feedMargin;
                CGFloat rightSpace = QDScreenW - leftMaxX;
                
                // 计算 Frame
                int row = i / numberOfItemsPerRow;
                    
                // 如果可以容纳小 Cell,即空缺出一段距离,将此行替换显示大 Cell, 并更新当前行其他 Item 位置
                if (rightSpace >= (QDScreenW - feedMargin * (numberOfItemsPerRow - 1)) / numberOfItemsPerRow) { // 可以容纳小 Cell且不是大 Cell
                    
                    itemY = lastAttrs.frame.origin.y + feedMargin;
                    
                    // 获取应该在的行,下移此行所有 cell
                    // 遍历此行前面的 attrs
                    
//                    NSInteger index = 0;
//                    // 计算行首 index
//                    NSInteger firstIndexOfRow = row * numberOfItemsPerRow;
                    
//                    for (index = firstIndexOfRow; index < i ; index++) {
//                        UICollectionViewLayoutAttributes *currentAttrs = self.attrsArray[index];
//                        CGRect F = currentAttrs.frame;
//                        itemY = F.origin.y + feedMargin;
//                        
//                        F.origin.y  = itemY + itemH + feedMargin;
//                        currentAttrs.frame = F;
//                    }
//                    // 对模型也进行调整,将大 Cell 的模型放到行首位置
//                    if (![self.attrsArray containsObject:attrs]) {
//                        [self.attrsArray insertObject:attrs atIndex:firstIndexOfRow];
//                    }
                    CGRect F = lastAttrs.frame;
                    F.origin.y = itemY + itemH + feedMargin;
                    lastAttrs.frame = F;
                    
                    // 插入
                    [self.attrsArray insertObject:attrs atIndex:0];
                }
            }
        }
        
        attrs.frame = CGRectMake(itemX, itemY, itemW, itemH);
        
        // 添加UICollectionViewLayoutAttributes
        if (![self.attrsArray containsObject:attrs]) {
            // 还没有添加过(没有在之前被插入)
            [self.attrsArray addObject:attrs];
        }
    }
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    return self.attrsArray;
}

/*!
 *  @brief  返回 contentSize
 *
 *  @return  返回ContentSize
 */
- (CGSize)collectionViewContentSize {
    return CGSizeMake(QDScreenW, CGRectGetMaxY([self.attrsArray.lastObject frame]));
}

/*!
 *  @brief  返回每一个 cell 的布局
 *
 *  @param indexPath  indexPath
 *
 *  @return  返回每一个 cell 的布局
 */
//- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
//
//    // 获取当前位置的模型,并根据类型属性判断应该返回什么样的 Cell
//    QDFeed *feed = self.feeds[indexPath.item];
//    
//    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
//    CGFloat numberOfItemsPerRow = 2;
//    CGFloat feedMargin = 3;
//    CGFloat itemX = 0;
//    CGFloat itemY = 0;
//    CGFloat itemW = QDScreenW;
//    CGFloat itemH = itemW + 50;
//    
//    if (indexPath.item == 0 || feed.type == QDFeedCellTypeCompact) { // 首页轮播图 或者 类型是大图
//        itemW = (QDScreenW - feedMargin) / numberOfItemsPerRow;
//        itemH = itemW * 9 / 16;             // 宽高比设为 16 : 9
//    }
//    
//    attrs.bounds = CGRectMake(0, 0, itemW , itemH);
//    
//    return attrs;
//}


@end
