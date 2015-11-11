//
//  QDPost.h
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDCategory;


typedef NS_ENUM(NSInteger, QDGenre) {
    /// 普通
    QDGenreNormal = 1,
    /// 报告
    QDGenreReport = 14,
    /// 最佳设计
    QDGenreBestOnTheWeb = 6,
    /// 投票
    QDGenreVote = 1000,
    /// 调查(我的)
    QDGenrePaper = 1001,
    /// 广告
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
/** 调查参加数量 */
@property (nonatomic, assign) NSInteger record_count;
/** 发布时间 */
@property (nonatomic, assign) NSInteger  publish_time;
/** 所属分类 */
@property (nonatomic, strong) QDCategory *category;
/** 文章排版风格 */
@property (nonatomic, assign) QDPageStyle page_style;
/** 文章地址 */
@property (nonatomic, copy)  NSString *appview;
/** 图片地址 */
@property (nonatomic, copy)  NSString *image;

/** 是否是新调查 */
@property (nonatomic, assign)  BOOL isNew;

@end
