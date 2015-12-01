//
//  QDFeedArticleViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/16.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDFeed;

@interface QDFeedArticleViewController : UIViewController
/** feed 模型 */
@property (nonatomic, strong) QDFeed *feed;
@end
