
//
//  QDSideMenuCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideMenuCell.h"
#import "QDSideMenuCategory.h"

@implementation QDSideMenuCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setCategory:(QDSideMenuCategory *)category {
    _category = category;;
    self.textLabel.text = category.title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
