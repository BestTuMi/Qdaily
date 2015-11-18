//
//  QDCommentCell.h
//  Qdaily
//
//  Created by Envy15 on 15/11/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDComment;

@interface QDCommentCell : UICollectionViewCell
/** 评论模型 */
@property (nonatomic, strong)  QDComment *comment;
/** cell 的高度 */
@property (nonatomic, assign)  CGFloat cellHeight;
@end
