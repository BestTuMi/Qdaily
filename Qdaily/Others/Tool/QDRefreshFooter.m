//
//  QDRefreshFooter.m
//  Qdaily
//
//  Created by Envy15 on 15/10/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDRefreshFooter.h"

@interface QDRefreshFooter ()
/** ImageView, 用于播动画 */
@property (nonatomic, weak) UIImageView *imageView;
@end

@implementation QDRefreshFooter

#pragma mark - lazyload
- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.contentMode = UIViewContentModeCenter;
        [self addSubview:imageView];
        self.imageView = imageView;
        
        // 设置正在刷新状态的动画图片
        NSMutableArray *refreshingImages = [NSMutableArray array];
        for (NSUInteger i = 1; i<=21; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"list_loading_%03zd", i]];
            [refreshingImages addObject:image];
        }
        
        imageView.animationImages = refreshingImages;
        imageView.animationDuration = 1.5;
        imageView.animationRepeatCount = MAXFLOAT;
    }
    return _imageView;
}

#pragma mark - 重写方法
#pragma mark 在这里做一些初始化配置（比如添加子控件）
- (void)prepare
{
    [super prepare];
    
    // 设置控件的高度
    self.mj_h = 50;
    
    // loading
    [self addSubview:self.imageView];
    
    // 控制开始刷新的位置
    self.triggerAutomaticallyRefreshPercent = 0;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.imageView.frame = self.bounds;
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
}

#pragma mark 监听scrollView的contentSize改变
- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    
}

#pragma mark 监听scrollView的拖拽状态改变
- (void)scrollViewPanStateDidChange:(NSDictionary *)change
{
    [super scrollViewPanStateDidChange:change];
    
}

#pragma mark 监听控件的刷新状态
- (void)setState:(MJRefreshState)state
{
    MJRefreshCheckState;
    switch (state) {
        case MJRefreshStateRefreshing:
            [self.imageView startAnimating];
            break;
        case MJRefreshStateNoMoreData:
            self.imageView.hidden = YES;
            break;
        default:
            break;
    }
}
@end
