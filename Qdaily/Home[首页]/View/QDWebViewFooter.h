//
//  QDWebViewFooter.h
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDWebViewFooter : UIView
/** 相关的 新闻 */
@property (nonatomic, copy) NSArray *relatedFeeds;
/** 推荐的 新闻 */
@property (nonatomic, copy) NSArray *recommendFeeds;
@end
