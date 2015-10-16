//
//  QDQTabCollectionViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QDHomeFeedArticleViewCollectionViewDelegate <NSObject>

@optional
- (void)homeFeedArticleViewCollectionView: (UICollectionView *)collectionView offsetChannged: (NSDictionary *)change;

@end

@interface QDHomeFeedArticleViewController : UIViewController
/** 代理 */
@property (nonatomic, weak)  id<QDHomeFeedArticleViewCollectionViewDelegate> delegate;
@end
