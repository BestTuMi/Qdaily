//
//  QDRecommendCell.h
//  Qdaily
//
//  Created by Envy15 on 15/11/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDRecommendCell;

@protocol RecommendCellDelegate <NSObject>

- (void)recommendCell: (QDRecommendCell *)cell didClickedAtIndex: (NSInteger)index;

@end

@interface QDRecommendCell : UICollectionViewCell
/** 推荐的新闻 */
@property (nonatomic, copy) NSArray *recommends;
/** 代理 */
@property (nonatomic, weak)  id<RecommendCellDelegate> delegate;
@end
