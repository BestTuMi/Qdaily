//
//  QDCollectionView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCollectionView.h"
#import "QDRefreshHeader.h"

@interface QDCollectionView () <UIGestureRecognizerDelegate>
/** 滚动开始时初始 offset */
@property (nonatomic, assign) CGPoint originalOffset;
/** 通知 */
@property (nonatomic, strong)  NSNotification *note;
@end

@implementation QDCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        
        // KVO 监听
        [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.header) {
        // 避免覆盖在视图上
        [self insertSubview:self.header atIndex:0];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

#pragma mark - lazy

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    CGPoint newOffset = [change[NSKeyValueChangeNewKey] CGPointValue];
    CGFloat newOffsetY = newOffset.y;
    CGFloat originalOffsetY = self.originalOffset.y;
    
    // 如果移动距离大于200,隐藏侧边菜单按钮....其他可能的操作
    CGFloat deltaOffsetY = newOffsetY - originalOffsetY;
    NSDictionary *userInfo = @{@"deltaOffsetY" : @(deltaOffsetY)};
    if (deltaOffsetY >= 100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QDCollectionViewIdelStateNotification object:nil userInfo:userInfo];
    } else if (deltaOffsetY <= -100) {
        [[NSNotificationCenter defaultCenter] postNotificationName:QDCollectionViewIdelStateNotification object:nil userInfo:userInfo];
    }
}

#pragma mark - 手势代理方法
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    // 记录刚开始滚动时的 offset
    self.originalOffset = self.contentOffset;
    return YES;
}

@end
