//
//  QDCommentField.m
//  Qdaily
//
//  Created by Envy15 on 15/11/25.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCommentField.h"

@implementation QDCommentField

#pragma mark - 第一响应者
- (BOOL)resignFirstResponder {
    // 隐藏评论输入框
    self.superview.alpha = 0;
    return [super resignFirstResponder];
}

@end
