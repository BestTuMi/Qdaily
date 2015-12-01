//
//  QDSeparateCell.m
//  Qdaily
//
//  Created by Envy15 on 15/11/18.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSeparateCell.h"
#import "Masonry.h"

@implementation QDSeparateCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = QDRGBWhiteColor(0.95, 1.0);
    
    UIView *topSeparateV = [[UIView alloc] init];
    topSeparateV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.contentView addSubview:topSeparateV];
    [topSeparateV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.top.equalTo(self.contentView.mas_top);
        make.height.equalTo(@(0.5));
    }];
    
    
    UIView *bottomSeparateV = [[UIView alloc] init];
    bottomSeparateV.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];
    [self.contentView addSubview:bottomSeparateV];
    [bottomSeparateV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.contentView.mas_leading);
        make.trailing.equalTo(self.contentView.mas_trailing);
        make.bottom.equalTo(self.contentView.mas_bottom);
        make.height.equalTo(@(0.5));
    }];
}

@end
