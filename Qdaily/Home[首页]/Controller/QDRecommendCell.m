//
//  QDRecommendCell.m
//  Qdaily
//
//  Created by Envy15 on 15/11/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDRecommendCell.h"
#import "QDFeed.h"
#import "QDPost.h"
#import <UIImageView+WebCache.h>

@interface QDRecommendCell () 
@property (weak, nonatomic) IBOutlet UIImageView *firstRecommendImageView;
@property (weak, nonatomic) IBOutlet UILabel *firstRecommendLabel;
@property (weak, nonatomic) IBOutlet UIImageView *twoImageView;
@property (weak, nonatomic) IBOutlet UILabel *twoLabel;
@property (weak, nonatomic) IBOutlet UIImageView *threeImageView;
@property (weak, nonatomic) IBOutlet UILabel *threeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fourImageView;
@property (weak, nonatomic) IBOutlet UILabel *fourLabel;
@property (weak, nonatomic) IBOutlet UIImageView *fiveImageView;
@property (weak, nonatomic) IBOutlet UILabel *fiveLabel;
@end

@implementation QDRecommendCell

- (void)setRecommends:(NSArray *)recommends {
    _recommends = recommends;
    
    [self.firstRecommendImageView sd_setImageWithURL:[NSURL URLWithString:((QDFeed *)recommends[0]).image]];
    self.firstRecommendLabel.text = ((QDFeed *)recommends[0]).post.title;
   
    [self.twoImageView sd_setImageWithURL:[NSURL URLWithString:((QDFeed *)recommends[1]).image]];
    self.twoLabel.text = ((QDFeed *)recommends[1]).post.title;
    
    [self.threeImageView sd_setImageWithURL:[NSURL URLWithString:((QDFeed *)recommends[2]).image]];
    self.threeLabel.text = ((QDFeed *)recommends[2]).post.title;

    
    [self.fourImageView sd_setImageWithURL:[NSURL URLWithString:((QDFeed *)recommends[3]).image]];
    self.fourLabel.text = ((QDFeed *)recommends[3]).post.title;
    
    [self.fiveImageView sd_setImageWithURL:[NSURL URLWithString:((QDFeed *)recommends[4]).image]];
    self.fiveLabel.text = ((QDFeed *)recommends[4]).post.title;
    
    //  添加手势
    for (UIView *view in self.subviews) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellClick:)];
        [view addGestureRecognizer:tapGesture];
    }
}

- (void)cellClick:(UITapGestureRecognizer *)tapGesture {
    NSInteger index = [self.subviews indexOfObject:tapGesture.view];
    if ([self.delegate respondsToSelector:@selector(recommendCell:didClickedAtIndex:)]) {
        [self.delegate recommendCell:self didClickedAtIndex:index];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // 转换点坐标
    CGPoint onePoint = [self.firstRecommendImageView convertPoint:point fromView:self];
    CGPoint twoPoint = [self.twoImageView convertPoint:point fromView:self];
    CGPoint threePoint = [self.threeImageView convertPoint:point fromView:self];
    CGPoint fourPoint = [self.fourImageView convertPoint:point fromView:self];
    CGPoint fivePoint = [self.fiveImageView convertPoint:point fromView:self];
    
    // 判断是否包含点(subview 中有系统自己的控件,因此这样判断更准确)
    if ([self.firstRecommendImageView pointInside:onePoint withEvent:nil]) {
        return self.firstRecommendImageView;
    } else if ([self.twoImageView pointInside:twoPoint withEvent:nil]) {
        return self.twoImageView;
    } else if ([self.threeImageView pointInside:threePoint withEvent:nil]) {
        return self.threeImageView;
    } else if ([self.fourImageView pointInside:fourPoint withEvent:nil]) {
        return self.fourImageView;
    } else if ([self.fiveImageView pointInside:fivePoint withEvent:nil]) {
        return self.fiveImageView;
    } else {
        return [super hitTest:point withEvent:event];
    }
}

@end
