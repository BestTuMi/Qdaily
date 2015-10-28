//
//  QDAnimateButton.h
//  Qdaily
//
//  Created by Envy15 on 15/10/23.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QDAnimateButton : UIControl
/** 点击菜单后的回调 */
@property (nonatomic, copy) void(^buttonHandler)(id sender);
+ (instancetype)button;
+ (instancetype)buttonWithOrigin:(CGPoint)origin;
- (void)touchUpInsideHandler:(BOOL)showMenu;
@end
