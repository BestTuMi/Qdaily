//
//  UIButton+Extension.m
//  Qdaily
//
//  Created by Envy15 on 15/10/21.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

- (void)setImage: (NSString *)image selectedImage: (NSString *)selectedImage {
    [self setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [self setImage:[UIImage imageNamed:selectedImage] forState:UIControlStateSelected];
}

@end
