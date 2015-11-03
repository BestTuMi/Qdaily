//
//  QDFeed.h
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QDCategory.h"
#import "QDPost.h"

typedef NS_ENUM(NSUInteger, QDFeedCellType) {
    QDFeedCellTypeSmall = 1,
    QDFeedCellTypeCompact = 2
};

@interface QDFeed : NSObject
/** 文章模型 */
@property (nonatomic, strong)  QDPost *post;
/** Cell 封面图 */
@property (nonatomic, copy) NSString *image;
/** Cell 的样式 */
@property (nonatomic, assign) QDFeedCellType type;
/** 标题 */
@property (nonatomic, copy)  NSString *title;
/** 详细标题 */
@property (nonatomic, copy)  NSString *detail;
@end
