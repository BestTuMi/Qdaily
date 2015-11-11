//
//  QDCollectionView.h
//  Qdaily
//
//  Created by Envy15 on 15/10/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDCollectionView : UICollectionView
/** 导航栏已隐藏,需要上滚 */
@property (nonatomic, assign) BOOL shouldScrollToTop;
@end
