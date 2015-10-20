//
//  UIBarButtonItem+Extension.m
//  Qdaily
//
//  Created by Envy15 on 15/10/4.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "UIBarButtonItem+Extension.h"

@implementation UIBarButtonItem (Extension)

+ (void)load {
    [[UIBarButtonItem appearance] setTintColor:QDRGBWhiteColor(1.0, 1.0)];
}

+ (instancetype)itemWithImage: (NSString *)image highlightedImage: (NSString *)highlightedImage target: (id)target action: (SEL)aSelector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:image] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImage] forState:UIControlStateHighlighted];
    [button sizeToFit];
    [button addTarget:target action:aSelector forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

@end
