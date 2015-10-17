//
//  QDRefreshHeader.m
//  Qdaily
//
//  Created by Envy15 on 15/10/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDRefreshHeader.h"

CGFloat const QDRefreshHeaderH = 104;
static inline double radians(double degrees) {
    return degrees / 180.0 * M_PI;
}

@interface QDRefreshHeader ()
/** foreground */
@property (nonatomic, weak) UIImageView *foregroundView;
/** 太阳 */
@property (nonatomic, weak) UIView *refreshComp;
/** 太阳图 */
@property (nonatomic, weak) UIImageView *refreshCompImage;

@end

@implementation QDRefreshHeader

- (void)prepare {
    [super prepare];
    
    self.mj_h = QDRefreshHeaderH;
    self.ignoredScrollViewContentInsetTop = - QDRefreshHeaderH;
    
    // 地面
    UIImageView *foregroundView = [[UIImageView alloc] init];
    foregroundView.image = [UIImage imageNamed:@"reveal_refresh_foreground"];
    [self addSubview:foregroundView];
    self.foregroundView = foregroundView;
    
    // 太阳\月亮
    UIImageView *refreshCompImage = [[UIImageView alloc] init];
    refreshCompImage.image = [UIImage imageNamed:@"reveal_refresh_sun"];
    self.refreshCompImage = refreshCompImage;
    UIView *refreshComp = [[UIView alloc] init];
    [refreshComp addSubview:refreshCompImage];
    [self addSubview:refreshComp];
    self.refreshComp = refreshComp;
}

#pragma mark 在这里设置子控件的位置和尺寸
- (void)placeSubviews
{
    [super placeSubviews];
    
    self.foregroundView.frame = self.bounds;
    
    CGFloat refreshCompWH = 25;
    CGFloat refreshCompX = self.width * 0.2;
    CGFloat refreshCompY = CGRectGetMaxY(self.foregroundView.frame) - refreshCompWH;
    self.refreshComp.frame = CGRectMake(refreshCompX, refreshCompY, refreshCompWH, refreshCompWH);
    self.refreshCompImage.frame = self.refreshComp.bounds;
   
}

#pragma mark 监听scrollView的contentOffset改变
- (void)scrollViewContentOffsetDidChange:(NSDictionary *)change
{
    [super scrollViewContentOffsetDidChange:change];
    
    // 在这里固定地面图的位置
    if (self.state == MJRefreshStateIdle) {
        self.foregroundView.y = self.scrollView.contentOffset.y + self.scrollViewOriginalInset.top;
    } else if (self.state == MJRefreshStatePulling || self.state == MJRefreshStateRefreshing) {
        self.foregroundView.y = - QDRefreshHeaderH;
    }
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
    MJRefreshCheckState
    if (state == MJRefreshStateIdle) {
        [self stopRotation];
    } else if (state == MJRefreshStatePulling || state == MJRefreshStateRefreshing) {
        QDLogFunc;
        [self startRotation];
    }
}

#pragma mark 监听拖拽比例（控件被拖出来的比例）
- (void)setPullingPercent:(CGFloat)pullingPercent
{
    [super setPullingPercent:pullingPercent];
    
    QDLogVerbose(@"%f", self.scrollView.contentOffset.y);
    
    CGFloat sy = (QDRefreshHeaderH - self.refreshComp.height) * pullingPercent;
    self.refreshComp.y = CGRectGetMaxY(self.foregroundView.frame) - sy;
    
    // 设置旋转
    if (pullingPercent <= 1) {
        self.refreshCompImage.layer.transform = CATransform3DMakeRotation(M_PI * 2 * pullingPercent, 0, 0, 1);
    }
}

- (void)startRotation {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.fromValue = @(0);
    anim.toValue = @(radians(180));
    anim.duration = 0.7;
    anim.repeatCount = MAXFLOAT;
    
    [self.refreshCompImage.layer addAnimation:anim forKey:nil];
}

- (void)stopRotation {
    // 移除动画
    [self.refreshCompImage.layer removeAllAnimations];
}

@end
