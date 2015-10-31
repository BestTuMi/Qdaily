//
//  QDCustomNaviBar.m
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCustomNaviBar.h"

@interface QDCustomNaviBar ()

@end

@implementation QDCustomNaviBar

+ (instancetype)naviBarWithTitle: (NSString *)title {
    return [[self alloc] initWithTitle:title];
}

- (instancetype)initWithTitle: (NSString *)title {
    if (self = [super init]) {
        if (title.length > 0) {
            self.title = title;
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addBlurViewWithAlpha:0.5];
    }
    return self;
}

- (UILabel *)titleView {
    if (!_titleView) {
        UILabel *titleView = [[UILabel alloc] init];
        titleView.textColor = QDRGBWhiteColor(1.0, 1.0);
        [self addSubview:titleView];
        _titleView = titleView;
    }
    return _titleView;
}

- (void)setFrame:(CGRect)frame {
    frame = CGRectMake(0, 0, QDScreenW, QDNaviBarMaxY);
    [super setFrame:frame];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleView.centerX = self.centerX;
    
    // 自定义的 naviBar高度包含了状态栏
    _titleView.centerY = QDStatusBarH + QDNaviBarH * 0.5;
}

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleView.text = title;
    [self.titleView sizeToFit];
}

- (void)setAttributedTitle: (NSAttributedString *)attributedTitle {
    self.titleView.attributedText = attributedTitle;
    [self.titleView sizeToFit];
}

@end
