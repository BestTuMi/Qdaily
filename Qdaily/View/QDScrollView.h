//
//  QDScrollView.h
//  Qdaily
//
//  Created by Envy15 on 15/10/9.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDScrollView : UIScrollView
/** 手势层数组 */
@property (nonatomic, strong)  NSMutableArray *gestureVArray;
- (void)setupGestureV;
@end
