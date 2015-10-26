//
//  QDSideMenuHeaderView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/12.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarHeaderView.h"
#import "Masonry.h"
#import "QDPentagonView.h"

@interface QDSideBarHeaderView ()
@property (weak, nonatomic) IBOutlet QDPentagonView *outerLine;
@property (weak, nonatomic) IBOutlet QDPentagonView *interLine;
@property (weak, nonatomic) IBOutlet QDPentagonView *radarView;
@property (weak, nonatomic) IBOutlet UIView *circleView;
@end

@implementation QDSideBarHeaderView

+ (instancetype)viewWithXib {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
}

- (void)awakeFromNib {
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    self.circleView.layer.cornerRadius = self.circleView.width * 0.5;
    self.circleView.layer.borderWidth = 1.0;
    self.circleView.layer.borderColor = [QDHighlightColor colorWithAlphaComponent:0.3].CGColor;
    
    // 设置绘制参数
    self.radarView.genes = @[@(0.54), @(0.54), @(0.54), @(0.54), @(0.54)];
    self.radarView.showType = 2;
    self.radarView.showWidtn = 1.0;
    
    // 设置绘制参数
    self.outerLine.genes = @[@(1.0), @(1.0), @(1.0), @(1.0), @(1.0)];
    self.outerLine.showType = 1; // 黑色半透明填充
    self.outerLine.showColor = [[UIColor redColor] colorWithAlphaComponent:0.2];
    
    self.interLine.genes = @[@(1.0), @(1.0), @(1.0), @(1.0), @(1.0)];
    self.interLine.showType = 1; // 黑色半透明填充
    self.interLine.showColor = [UIColor blueColor];
}

@end
