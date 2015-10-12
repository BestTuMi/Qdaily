//
//  QDPost.h
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDCategory;

typedef NS_ENUM(NSUInteger, QDGenre) {
    QDGenreNormal = 1,
    QDGenreBestOnTheWeb = 6,
    QDGenreVote = 1000,
    QDGenreAD = 16
};

/*!
 *  @brief  文章排版风格
 */
typedef NS_ENUM(NSUInteger, QDPageStyle){
    /*!
     *  专题内容
     */
    QDPageStyleSpecialTopic = 0,
    /*!
     *   文章 Banner 区使用大图
     */
    QDPageStyleLargeImage = 1,
    /*!
     *  文章 Banner 区使用小图
     */
    QDPageStyleSmallImage = 2
};

@interface QDPost : NSObject
/** 内容的 ID */
@property (nonatomic, copy) NSString *ID;
/** 内容样式 */
@property (nonatomic, assign) NSInteger genre;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** 副标题(描述) */
@property (nonatomic, copy) NSString *detail;
/** 评论数量 */
@property (nonatomic, assign) NSInteger comment_count;
/** 点赞数量 */
@property (nonatomic, assign) NSInteger praise_count;
/** 发布时间 */
@property (nonatomic, assign) NSInteger  publish_time;
/** 所属分类 */
@property (nonatomic, strong) QDCategory *category;
/** 文章排版风格 */
@property (nonatomic, assign) QDPageStyle page_style;
/** 文章地址 */
@property (nonatomic, copy)  NSString *appview;
@end
