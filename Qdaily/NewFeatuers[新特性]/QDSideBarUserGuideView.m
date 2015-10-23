//
//  QDSideBarUserGuideView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarUserGuideView.h"
#import "masonry.h"

@implementation QDSideBarUserGuideView

+ (void)show {
    QDSideBarUserGuideView *sideBarGuideV = [self sideBarUserGuideView];
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:sideBarGuideV];
    
    // 设置偏好设置,下次不再显示新手引导
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:QDShowSideBarUserGuideKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (instancetype)sideBarUserGuideView {
    QDSideBarUserGuideView *sideBarGuideV = [[self alloc] init];
    sideBarGuideV.frame = [UIScreen mainScreen].bounds;
    
    // 设置子控件
    UIImageView *guideV = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mainRoot_sliderbar_guide"]];
    [sideBarGuideV addSubview:guideV];
    [guideV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(sideBarGuideV);
    }];
    
    
    sideBarGuideV.backgroundColor = QDRGBWhiteColor(0, 0.5);
    
    return sideBarGuideV;
}

#pragma mark - 隐藏
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [self removeFromSuperview];
}

@end
