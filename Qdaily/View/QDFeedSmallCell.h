//
//  QDFeedSmallCell.h
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDPost;

@interface QDFeedSmallCell : UICollectionViewCell
/** 文章模型 */
@property (nonatomic, strong)  QDPost *post;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@end
