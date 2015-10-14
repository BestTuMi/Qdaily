//
//  QDFeedPaperCell.h
//  Qdaily
//
//  Created by Envy15 on 15/10/13.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDFeed;

@interface QDFeedPaperCell : UICollectionViewCell
/** 新闻信息 */
@property (nonatomic, strong) QDFeed *feed;
/** 返回 XIB 描述的对象 */
+ (instancetype)feedPaperCell;
@end
