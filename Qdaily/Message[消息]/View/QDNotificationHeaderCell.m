//
//  QDNotificationHeaderCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/22.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDNotificationHeaderCell.h"

@interface QDNotificationHeaderCell ()

@end

@implementation QDNotificationHeaderCell

static NSString *const notifyHeaderCell = @"notifyHeaderCell";

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:notifyHeaderCell];
    return [tableView dequeueReusableCellWithIdentifier:notifyHeaderCell];
}

- (void)awakeFromNib {
}

- (void)setFrame:(CGRect)frame {
    CGFloat margin = 3;
    frame.origin.y += margin;
    frame.origin.x = margin;
    frame.size.width -= margin * 2;
    [super setFrame:frame];
}

@end
