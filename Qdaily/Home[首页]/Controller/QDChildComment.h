//
//  QDChildComment.h
//  Qdaily
//
//  Created by Envy15 on 15/11/18.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDComment.h"
@class QDAuthor;

@interface QDChildComment : QDComment
/** 父级评论 Id */
@property (nonatomic, assign) NSInteger root_id;
/** 父级用户 */
@property (nonatomic, strong) QDAuthor *parent_user;
/** 是否最后一条评论 */
@property (nonatomic, assign)  BOOL isLastComment;
@end