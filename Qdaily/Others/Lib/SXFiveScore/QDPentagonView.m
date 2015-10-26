//
//  QDPentagonView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/12.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDPentagonView.h"

#define baseNum 1

static inline double radians(double degree) {
    return degree / 180.0 * M_PI;
}

@implementation QDPentagonView

- (void)awakeFromNib
{
    self.subScore1 = [self.genes[0] floatValue];
    self.subScore2 = [self.genes[1] floatValue];
    self.subScore3 = [self.genes[2] floatValue];
    self.subScore4 = [self.genes[3] floatValue];
    self.subScore5 = [self.genes[4] floatValue];
    
}

- (void)drawRect:(CGRect)rect {

    float subScore1,subScore2,subScore3,subScore4,subScore5;
    float x1,y1,x2,y2,x3,y3,x4,y4,x5,y5;
    
    subScore1 = self.subScore1;
    subScore2 = self.subScore2;
    subScore3 = self.subScore3;
    subScore4 = self.subScore4;
    subScore5 = self.subScore5;
    
    
    // 半径
    CGFloat r = self.width * 0.5;
    // 边长
    CGFloat l = r * cos(radians(54)) * 2;
    
    // ------因为设置了权值这里需要更改下比例
    CGFloat ratio1 = (subScore1-(1.0-baseNum)) / 1.0;
    CGFloat ratio2 = subScore2-(1.0-baseNum) / 1.0;
    CGFloat ratio3 = subScore3-(1.0-baseNum) / 1.0;
    CGFloat ratio4 = subScore4-(1.0-baseNum) / 1.0;
    CGFloat ratio5 = subScore5-(1.0-baseNum) / 1.0;
    
    // 右下角
    x1 = r + r * cos(radians(54));
    y1 = r + r * sin(radians(54));
    
    // 左下角
    x2 = r - r * cos(radians(54));
    y2 = r + r * sin(radians(54));
    
    // 左中
    x3 = x2 - l * cos(radians(72));
    y3 = y2 - l * sin(radians(72));
    
    // 顶
    x4 = r;
    y4 = 0;
    
    // 右中
    x5 = x1 + l * cos(radians(72));
    y5 = y3;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //-----------------------------------------画线段
//    CGContextMoveToPoint(ctx, x1, y1);
//    CGContextAddLineToPoint(ctx, x2, y2);
//    CGContextAddLineToPoint(ctx, x3, y3);
//    CGContextAddLineToPoint(ctx, x4, y4);
//    CGContextAddLineToPoint(ctx, x5, y5);
//    CGContextAddLineToPoint(ctx, x1, y1);
    
    CGContextMoveToPoint(ctx, (x1 - r) * ratio1 + r, (y1 - r) * ratio1 + r);
    CGContextAddLineToPoint(ctx, (x2 - r) * ratio2 + r, (y2- r) * ratio2 + r);
    CGContextAddLineToPoint(ctx, (x3 - r) * ratio3 + r, (y3 - r) * ratio3 + r);
    CGContextAddLineToPoint(ctx, (x4 - r) * ratio4 + r, (y4 - r) * ratio4 + r);
    CGContextAddLineToPoint(ctx, (x5 - r) * ratio5 + r, (y5 - r) * ratio5 + r);
    CGContextAddLineToPoint(ctx, (x1 - r) * ratio1 + r, (y1 - r) * ratio1 + r);

    
    [self showTheFiveScoreWithContext:ctx];
}

- (void)showTheFiveScoreWithContext:(CGContextRef)ctx
{
    CGContextSetLineWidth(ctx, self.showWidtn);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    if (self.showType == 1) { // 填充
        CGContextSetFillColorWithColor(ctx, self.showColor.CGColor);
        CGContextFillPath(ctx);
    }else if (self.showType == 2){ // 描边
        CGContextSetStrokeColorWithColor(ctx, QDHighlightColor.CGColor);
        CGContextStrokePath(ctx);
    }
}


@end
