//
//  QDAnimateButton.m
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDAnimateButton.h"
#import <POP/POP.h>

static CGFloat const buttonWH = 15;
static CGFloat const buttonBackgroundWH = 37;

@interface QDAnimateButton ()
@property(nonatomic) CALayer *topLayer;
@property(nonatomic) CALayer *middleLayer;
@property(nonatomic) CALayer *bottomLayer;
/** 添加动画组件的层 */
@property (nonatomic)  CALayer *animationLayer;
@property(nonatomic) BOOL showMenu;

/** 定时器 */
@property (nonatomic, weak) NSTimer *timer;

- (void)animateToMenu;
- (void)animateToArrow;
- (void)setup;
- (void)removeAllAnimations;
@end

@implementation QDAnimateButton

+ (instancetype)button
{
    return [self buttonWithOrigin:CGPointZero];
}

+ (instancetype)buttonWithOrigin:(CGPoint)origin
{
    return [[self alloc] initWithFrame:CGRectMake(origin.x,
                                                  origin.y,
                                                  buttonBackgroundWH,
                                                  buttonBackgroundWH)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

#pragma mark - Instance methods

- (void)tintColorDidChange
{
    CGColorRef color = [self.tintColor CGColor];
    self.topLayer.backgroundColor = color;
    self.middleLayer.backgroundColor = color;
    self.bottomLayer.backgroundColor = color;
}

#pragma mark - Private Instance methods

- (void)animateToMenu
{
    [self removeAllAnimations];
    
    // 清空形变
    self.topLayer.transform = CATransform3DIdentity;
    self.middleLayer.transform = CATransform3DIdentity;
    self.bottomLayer.transform = CATransform3DIdentity;
    
    // 移动到中心
    self.topLayer.position = CGPointMake(CGRectGetMaxX(self.animationLayer.bounds), CGRectGetMidY(self.animationLayer.bounds));
    self.bottomLayer.position = CGPointMake(CGRectGetMaxX(self.animationLayer.bounds), CGRectGetMidY(self.animationLayer.bounds));
    
    CFTimeInterval delay = 3 / 25.0;
    
    // 中线重新显示的动画
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeAnimation.duration = 0.5;
    fadeAnimation.beginTime = CACurrentMediaTime() + delay;
    fadeAnimation.toValue = @1;
    
    // 中心位置开始回到顶部
    POPBasicAnimation *positionTopAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionTopAnimation.duration = 0.3;
    positionTopAnimation.beginTime = CACurrentMediaTime() + delay ; // 为了看到先执行回到中线的效果
    positionTopAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.animationLayer.bounds),
                                                                         CGRectGetMinY(self.animationLayer.bounds))];
    
    POPBasicAnimation *positionBottomAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionBottomAnimation.duration = 0.3;
    positionBottomAnimation.beginTime = CACurrentMediaTime() + delay ; // 为了看到先执行回到中线的效果
    positionBottomAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.animationLayer.bounds),
                                                                            CGRectGetMaxY(self.animationLayer.bounds))];
    
    
    POPBasicAnimation *transformMiddleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
    transformMiddleAnimation.duration = 0.5;
    transformMiddleAnimation.toValue = @(1.0);
    
    [self.topLayer pop_addAnimation:positionTopAnimation forKey:@"positionTopAnimation"];
    [self.middleLayer pop_addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    [self.middleLayer pop_addAnimation:transformMiddleAnimation forKey:@"scaleMiddleAnimation"];
    [self.bottomLayer pop_addAnimation:positionBottomAnimation forKey:@"positionBottomAnimation"];
}

- (void)animateToArrow
{
    [self removeAllAnimations];
    
    CGFloat height = 2.f;
    
    // 淡出动画,由中线执行
    POPBasicAnimation *fadeAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerOpacity];
    fadeAnimation.toValue = @0;
    fadeAnimation.duration = 0.3;
    
    // 中线向左收缩至0
    POPBasicAnimation *transformMiddleAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerScaleX];
    transformMiddleAnimation.toValue = @(0);
    transformMiddleAnimation.duration = 0.3;
    
    // 顶线逆时针旋转45度,锚点为右侧
    POPBasicAnimation *transformTopAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformTopAnimation.toValue = @(- M_PI_4);
    transformTopAnimation.duration = 0.3;
    
    // 顶线同时往上升高一些
    POPBasicAnimation *positionTopAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionTopAnimation.duration = 0.3;
    positionTopAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.animationLayer.bounds) * 0.5 * sqrt(2),
                                                                         CGRectGetMidY(self.animationLayer.bounds) - CGRectGetWidth(self.animationLayer.bounds) * 0.5 * sqrt(2) - height * 0.5)];
    
    // 底线顺时针旋转45度,锚点为右侧
    POPBasicAnimation *transformBottomAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerRotation];
    transformBottomAnimation.toValue = @(M_PI_4);
    transformBottomAnimation.duration = 0.3;
    
    // 底线同时往下走一点
    POPBasicAnimation *positionBottomAnimation = [POPBasicAnimation animationWithPropertyNamed:kPOPLayerPosition];
    positionBottomAnimation.duration = 0.3;
    positionBottomAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake(CGRectGetWidth(self.animationLayer.bounds) * 0.5 * sqrt(2) ,
                                                                         CGRectGetMidY(self.animationLayer.bounds) + CGRectGetWidth(self.animationLayer.bounds) * 0.5 + height * 0.5)];
    
    [self.middleLayer pop_addAnimation:fadeAnimation forKey:@"fadeAnimation"];
    [self.middleLayer pop_addAnimation:transformMiddleAnimation forKey:@"scaleMiddleAnimation"];
    [self.topLayer pop_addAnimation:transformTopAnimation forKey:@"rotateTopAnimation"];
    [self.topLayer pop_addAnimation:positionTopAnimation forKey:@"positionTopAnimation"];
    [self.bottomLayer pop_addAnimation:transformBottomAnimation forKey:@"rotateBottomAnimation"];
    [self.bottomLayer pop_addAnimation:positionBottomAnimation forKey:@"positionBottomAnimation"];
}

- (void)touchUpInsideHandler
{
    if (self.showMenu) {
        [self animateToMenu];
    } else {
        [self animateToArrow];
    }
    self.showMenu = !self.showMenu;
}

- (void)setup
{
    // 添加动画组件层
    self.animationLayer = [CALayer layer];
    self.animationLayer.bounds = CGRectMake(0, 0, buttonWH, buttonWH);
    self.animationLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    [self.layer addSublayer:self.animationLayer];
    
    CGFloat height = 2.f;
    CGFloat width = CGRectGetWidth(self.animationLayer.bounds);
    CGFloat cornerRadius =  1.f;
    CGColorRef color = [self.tintColor CGColor];
    
    self.topLayer = [CALayer layer];
    self.topLayer.anchorPoint = CGPointMake(1, 0.5);
    self.topLayer.frame = CGRectMake(0, CGRectGetMinY(self.animationLayer.bounds), width, height);
    self.topLayer.cornerRadius = cornerRadius;
    self.topLayer.backgroundColor = color;
    
    self.middleLayer = [CALayer layer];
    self.middleLayer.anchorPoint = CGPointMake(0, 0.5);
    self.middleLayer.frame = CGRectMake(0, CGRectGetMidY(self.animationLayer.bounds)-(height/2), width, height);
    self.middleLayer.cornerRadius = cornerRadius;
    self.middleLayer.backgroundColor = color;
    
    self.bottomLayer = [CALayer layer];
    self.bottomLayer.anchorPoint = CGPointMake(1, 0.5);
    self.bottomLayer.frame = CGRectMake(0, CGRectGetMaxY(self.animationLayer.bounds)-height, width, height);
    self.bottomLayer.cornerRadius = cornerRadius;
    self.bottomLayer.backgroundColor = color;
    
    [self.animationLayer addSublayer:self.topLayer];
    [self.animationLayer addSublayer:self.middleLayer];
    [self.animationLayer addSublayer:self.bottomLayer];
    
    // 背景设置
    self.layer.cornerRadius = CGRectGetWidth(self.bounds) * 0.5;
    self.layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8].CGColor;
    
    // 监听通知,控制自己的显示和隐藏
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateStatus:) name:QDCollectionViewIdelStateNotification object:nil];
    // 已停止滚动,开启定时器
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startTimer) name:QDCollectionViewDidEndScrollNotification object:nil];
}

- (void)removeAllAnimations
{
    [self.topLayer pop_removeAllAnimations];
    [self.middleLayer pop_removeAllAnimations];
    [self.bottomLayer pop_removeAllAnimations];
}

- (void)updateStatus: (NSNotification *)note {
    // 取出 deltaOffsetY
    CGFloat deltaOffsetY = [note.userInfo[@"deltaOffsetY"] doubleValue];
    if (deltaOffsetY > 0) { // 向上滑,隐藏按钮
        self.hidden = YES;
    } else {
        self.hidden = NO;
    }
}

- (void)setHidden:(BOOL)hidden {
    [UIView animateWithDuration:0.25 animations:^{
        if (hidden) {
            self.alpha = 0;
        } else {
            self.alpha = 1.0;
        }
    }];
}

- (void)startTimer {
    [self stopTimer];
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(show) userInfo:nil repeats:NO];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    self.timer = timer;
}

- (void)show {
    
    [self stopTimer];
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = 1.0;
    }];
}

- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopTimer];
}

@end
