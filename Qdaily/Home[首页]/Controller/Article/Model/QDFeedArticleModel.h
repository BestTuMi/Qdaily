//
//  QDFeedArticleModel.h
//  Qdaily
//
//  Created by Envy15 on 15/11/14.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDFeedArticleModel : NSObject
/** 文章 id*/
@property (nonatomic, copy) NSString *Id;
/** 文章 html 部分 */
@property (nonatomic, copy)  NSString *body;
/** 文章的 css */
@property (nonatomic, copy) NSArray *css;
/** 文章的 js */
@property (nonatomic, copy) NSArray *js;
/** 文章的图片 */
@property (nonatomic, copy) NSArray *image;
@end
