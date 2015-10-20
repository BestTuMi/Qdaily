//
//  QDResult.h
//  Qdaily
//
//  Created by Envy15 on 15/10/20.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDAuthor;
@class QDPost;

@interface QDResult : NSObject
/** 新闻模型 */
@property (nonatomic, strong)  QDPost *post;
/** 作者模型 */
@property (nonatomic, strong)  QDAuthor *author;
@end
