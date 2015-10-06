//
//  UIBarButtonItem+Extension.h
//  Qdaily
//
//  Created by Envy15 on 15/10/4.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIBarButtonItem (Extension)
+ (instancetype)itemWithImage: (NSString *)image highlightedImage: (NSString *)highlightedImage target: (id)target action: (SEL)aSelector;
@end
