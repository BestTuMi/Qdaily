//
//  QDMainUserGuideView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDMainUserGuideView.h"
#import "masonry.h"

@implementation QDMainUserGuideView

+ (void)show {
    QDMainUserGuideView *mainGuideV = [self mainUserGuideView];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:mainGuideV];
    
    // 设置偏好设置,下次不再显示新手引导
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:QDShowMainUserGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)hide {
    for (UIView *view in [UIApplication sharedApplication].keyWindow.subviews) {
        if ([view isKindOfClass:[self class]]) {
            [view removeFromSuperview];
        }
    }
}

+ (instancetype)mainUserGuideView {
    QDMainUserGuideView *mainGuideV = [[self alloc] init];
    mainGuideV.frame = [UIScreen mainScreen].bounds;
    
    // 设置子控件
    UIImageView *guideCenterV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"article_feed_guide_center"]];
    [mainGuideV addSubview:guideCenterV];
    [guideCenterV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(mainGuideV);
    }];
    
    UIImageView *guideBottomV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"article_feed_guide_bottom"]];
    [mainGuideV addSubview:guideBottomV];
    [guideBottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(mainGuideV);
        make.bottom.equalTo(mainGuideV);
    }];
    
    UIImageView *guideLeftBottomV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"article_feed_guide_leftBottom"]];
    [mainGuideV addSubview:guideLeftBottomV];
    [guideLeftBottomV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(mainGuideV);
        make.bottom.equalTo(guideBottomV.mas_top);
    }];
    
    // 添加按钮,相应展开菜单的点击
    UIButton *sideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [sideButton addTarget:self action:@selector(sideButtonClick) forControlEvents:UIControlEventTouchDown];
    [mainGuideV addSubview:sideButton];
    [sideButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(15));
        make.bottom.equalTo(@(- 15));
        make.width.equalTo(@(50));
        make.height.equalTo(@(50));
    }];
    
    mainGuideV.backgroundColor = QDRGBWhiteColor(0, 0.5);
    
    return mainGuideV;
}

+ (void)sideButtonClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:QDShowSideBarNNotification object:nil];
    [self hide];
}

#pragma mark - 隐藏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}


@end
