//
//  QDNewFeaturesCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNewFeaturesCell.h"
#import "Masonry.h"

@interface QDNewFeaturesCell ()

@end

@implementation QDNewFeaturesCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageview = [[UIImageView alloc] initWithFrame:self.bounds];
        [self.contentView addSubview:imageview];
        _imageView = imageview;
        
        UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [startButton setTitle:@"开启阅读" forState: UIControlStateNormal];
        startButton.layer.borderWidth = 1.0;
        startButton.layer.borderColor = QDRGBWhiteColor(1.0, 1.0).CGColor;
        [startButton addBlurViewWithLightColor];
        [startButton addTarget:self action:@selector(startButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:startButton];
        _startButton = startButton;
        
        // 布局
        [startButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(- 100);
            make.centerX.equalTo(self.mas_centerX);
            make.width.equalTo(@(150));
            make.height.equalTo(@(44));
        }];
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    // 将开启按钮提到最前
    [self.contentView addSubview:self.startButton];
}

- (void)startButtonClick {
    [[NSNotificationCenter defaultCenter] postNotificationName:QDChangeRootVCNotification object:self userInfo:nil];
}

@end
