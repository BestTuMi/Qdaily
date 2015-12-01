//
//  QDComment.h
//  Qdaily
//
//  Created by Envy15 on 15/11/18.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>
@class QDAuthor;
@class QDChildComment;

@interface QDComment : NSObject

/** 评论的 ID */
@property (nonatomic, assign) NSInteger Id;
/** 评论数 */
@property (nonatomic, assign) NSInteger comment_count;
/** 点赞数 */
@property (nonatomic, assign) NSInteger praise_count;
/** 评论内容 */
@property (nonatomic, copy)  NSString *content;
/** 其他人的回复 */
@property (nonatomic, strong)  NSArray *child_comments;
/** 发布时间 */
@property (nonatomic, assign) NSInteger publish_time;
/** 发帖人的信息 */
@property (nonatomic, strong)  QDAuthor *author;

@end
