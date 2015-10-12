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
        
        int numberOfItemsPerRow = 2;
        CGFloat feedMargin = 3;
        CGFloat itemX = 0;
        CGFloat itemY = 0;
        CGFloat itemW = QDScreenW;
        CGFloat itemH = itemW * 173 / 320;
        
        if (i != 0) {

            if (feed.type == QDFeedCellTypeSmall) { // 类型是小图
                itemW = (QDScreenW - feedMargin) / numberOfItemsPerRow;
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
                    itemY = CGRectGetMaxY(lastAttrs.frame) + feedMargin;
                }
            } else { // 大图

                UICollectionViewLayoutAttributes *lastAttrs = self.attrsArray[i - 1];
                // 计算右边剩余空间
                CGFloat leftMaxX = CGRectGetMaxX(lastAttrs.frame) + feedMargin;
                CGFloat rightSpace = QDScreenW - leftMaxX;
                // 计算 Frame
                itemY = CGRectGetMaxY(lastAttrs.frame) + feedMargin;
                
                // 如果计算后的 大 Cell是因为空间不足而换行,即空缺出一段距离
                if (rightSpace >= lastAttrs.frame.size.width && lastAttrs.frame.size.width != itemW) { // 可以容纳小 Cell且不是大 Cell
                    // 获取应该在的行,下移此行所有 cell
                    // 遍历此行前面的 attrs
                    int row = i / numberOfItemsPerRow;
                    int index = 0;
                    for (index = row * numberOfItemsPerRow; index < i; index++) {
                        UICollectionViewLayoutAttributes *attrs = self.attrsArray[index];
                        CGRect F = attrs.frame;
                        F.origin.y = attrs.frame.origin.y + itemH + feedMargin;
                        attrs.frame = F;
                    }
                    // 将 Frame 设为当前行,即不换行
                    itemY = lastAttrs.frame.origin.y;
                    
                    // 对模型也进行调整,将大 Cell 的模型放到行首位置
                    [self.attrsArray removeObject:attrs];
                    [self.attrsArray insertObject:attrs atIndex:row *numberOfItemsPerRow];
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
