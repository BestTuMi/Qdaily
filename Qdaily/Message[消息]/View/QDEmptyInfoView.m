//
//  QDEmptyInfoView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDEmptyInfoView.h"
#import "masonry.h"

@interface QDEmptyInfoView ()
/** 标题标签 */
@property (nonatomic, weak) UILabel *label;
/** 图标 */
@property (nonatomic, weak)  UIImageView *imageView;
@end

@implementation QDEmptyInfoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = QDLightGrayColor;
        
        // 设置背景视图子控件
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"favorite_default_empty"]];
        _imageView = imageView;
        [self addSubview:imageView];
        // 设置约束
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.mas_top).offset((QDScreenH - QDNaviBarMaxY - QDToolBarH - imageView.height) * 0.5);
        }];
        
        UILabel *label = [[UILabel alloc] init];
        _label = label;
        self.title = @"我收到的评论会出现在这里";
        label.textColor = [UIColor lightGrayColor];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(imageView);
            make.top.equalTo(imageView.mas_bottom).offset(15);
        }];
    }
    return self;
}

- (void)setTitle:(NSString *)title {
    _label.text = title;
}

- (NSString *)title {
    return _label.text;
}

// 调整内容约束
- (void)setContentPosition:(CGPoint)position {
     [self.imageView mas_updateConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(@(position.y));
     }];
}

#pragma mark - 显示隐藏背景上的图标和文字
- (void)hideEmptyViewInfo {
    self.label.hidden = YES;
    self.imageView.hidden = YES;
}

- (void)showEmptyViewInfo {
    self.label.hidden = NO;
    self.imageView.hidden = NO;
}

@end
