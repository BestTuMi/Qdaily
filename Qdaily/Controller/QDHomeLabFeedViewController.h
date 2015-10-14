//
//  QDLabTabCollectionViewController.h
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QDHomeLabFeedViewCollectionViewDelegate <NSObject>

@optional
- (void)homeLabFeedViewCollectionView: (UICollectionView *)collectionView offsetChannged: (NSDictionary *)change;

@end

@interface QDHomeLabFeedViewController : UIViewController
/** 代理 */
@property (nonatomic, weak)  id<QDHomeLabFeedViewCollectionViewDelegate> delegate;
@end
