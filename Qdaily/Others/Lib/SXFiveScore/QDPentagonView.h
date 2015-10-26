//
//  QDPentagonView.h
//  Qdaily
//
//  Created by Envy15 on 15/10/12.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDPentagonView : UIView

@property(nonatomic,assign)CGFloat subScore1;
@property(nonatomic,assign)CGFloat subScore2;
@property(nonatomic,assign)CGFloat subScore3;
@property(nonatomic,assign)CGFloat subScore4;
@property(nonatomic,assign)CGFloat subScore5;

/** genes */
@property (nonatomic, copy) NSArray *genes;

@property(nonatomic,assign)int showType;
@property(nonatomic,strong)UIColor *showColor;
@property(nonatomic,assign)float showWidtn;

@end
