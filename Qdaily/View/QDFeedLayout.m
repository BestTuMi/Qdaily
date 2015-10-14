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
        
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForItemAtIndexPath:indexPath];
        
        [self.attrsArray addObject:attrs];
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
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    UICollectionViewLayoutAttributes *attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    // 设置布局属性
    
    // 获取当前位置的模型,并根据类型属性判断应该返回什么样的 Cell
    QDFeed *feed = self.feeds[indexPath.item];
    QDFeed *previousFeed = (indexPath.item == 0 || indexPath.item == 1 ) ? nil : self.feeds[indexPath.item - 1];
    NSInteger count = self.feeds.count;
    
    int numberOfItemsPerRow = 2;
    CGFloat feedMargin = 3;
    CGFloat itemX = 0;
    CGFloat itemY = 0;
    CGFloat itemW = QDScreenW;
    CGFloat itemH = itemW * 173 / 320;
    
    if (indexPath.item != 0 || [feed isKindOfClass:[QDFeed class]]) { // 轮播图需要跳过
        
        if (feed.type == QDFeedCellTypeSmall && feed.post.genre != QDGenreReport) { // 类型是小图
            itemW = (QDScreenW - feedMargin * (numberOfItemsPerRow - 1)) / numberOfItemsPerRow;
            itemH = itemW * 195 / 158.5;
            // 获取最后一个attrs
            UICollectionViewLayoutAttributes *lastAttrs = self.attrsArray.lastObject;
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
            
            if (feed.post.genre == QDGenreVote || feed.post.genre == QDGenrePaper || feed.post.genre == QDGenreReport) { // 不等高带文字
                itemH = QDPaperImageH + QDCommonMargin;
                NSString *paperTitle = feed.post.title;
                NSString *paperDetailTitle = feed.post.detail;
                CGFloat paperTitleH = [paperTitle boundingRectWithSize:CGSizeMake(QDScreenW - QDPaperTextLeftMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:17]} context:nil].size.height;
                
                itemH += paperTitleH + QDCommonMargin;
                
                CGFloat paperDetailTitleH = [paperDetailTitle boundingRectWithSize:CGSizeMake(QDScreenW - QDPaperTextLeftMargin * 2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]} context:nil].size.height;
                
                // 单行高度
                CGFloat singleLineH = [paperDetailTitle sizeWithAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}].height;
                if (paperDetailTitleH >= 3 * singleLineH) { // 末尾省略文字高度也会被计算
                    paperDetailTitleH = 3 * singleLineH;
                }
                
                itemH += paperDetailTitleH + QDCommonMargin;
            }
            
            // 获取最后一个attrs
            UICollectionViewLayoutAttributes *lastAttrs = self.attrsArray.lastObject;

            itemY = CGRectGetMaxY(lastAttrs.frame) + feedMargin;
            
            // 计算右边剩余空间
            CGFloat leftMaxX = CGRectGetMaxX(lastAttrs.frame) + feedMargin;
            CGFloat rightSpace = QDScreenW - leftMaxX;
            
            // 计算 Frame
            NSInteger row = indexPath.item / numberOfItemsPerRow;
            
            // 如果可以容纳小 Cell,即空缺出一段距离,将此行替换显示大 Cell, 并更新当前行其他 Item 位置
            if (rightSpace >= (QDScreenW - feedMargin * (numberOfItemsPerRow - 1)) / numberOfItemsPerRow) { // 可以容纳小 Cell且不是大 Cell
                
                itemY = lastAttrs.frame.origin.y + feedMargin;
                
                /******
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
                 *********/
                CGRect F = lastAttrs.frame;
                F.origin.y = itemY + itemH + feedMargin;
                lastAttrs.frame = F;
                
                // 插入
                [self.attrsArray insertObject:attrs atIndex:0];
                
            }
        }
    }
    
    if (indexPath.item == 0) {
        itemY = 0;
    }
    
    attrs.frame = CGRectMake(itemX, itemY, itemW, itemH);
    
    if ([self.attrsArray containsObject:attrs]) { // 前面插入过
        return self.attrsArray.lastObject;
    } else {
        return attrs;
    }
}


@end
