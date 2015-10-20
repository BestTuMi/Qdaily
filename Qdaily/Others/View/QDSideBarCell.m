
//
//  QDSideMenuCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSideBarCell.h"
#import "QDSideBarCategory.h"
#import <UIImageView+WebCache.h>
#import <UIImageView+HighlightedWebCache.h>
#import "QDCategoryFeedViewController.h"

@interface QDSideBarCell ()
/** 图标控件 */
@property (nonatomic, weak)  UIImageView *image_view;
/** 标签控件 */
@property (nonatomic, weak) UILabel *text_Label;
@end

@implementation QDSideBarCell

- (void)awakeFromNib {
    // Initialization code
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        // 背景透明
        self.backgroundColor = [UIColor clearColor];
        
        // 自定义图标控件
        UIImageView *image_view = [[UIImageView alloc] init];
        image_view.bounds = CGRectMake(0, 0, 33, 33);
        [self.contentView addSubview:image_view];
        _image_view = image_view;
        
        // 自定义标题控件
        UILabel *text_label = [[UILabel alloc] init];
        [self.contentView addSubview:text_label];
        
        // 设置标签选中色和普通色
        text_label.textColor = QDNormalColor;
        text_label.highlightedTextColor = QDHighlightColor;
        _text_Label = text_label;
        
        // 设置 Cell 选中后的效果
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

// 布局子控件
- (void)layoutSubviews {
    [super layoutSubviews];
    _image_view.x = 20;
    
    _text_Label.x = CGRectGetMaxX(_image_view.frame) + 25;
    _text_Label.y = 0;
    _text_Label.height = 44;
    _image_view.centerY = _text_Label.centerY;
}

- (void)setCategory:(QDSideBarCategory *)category {
    _category = category;
    _text_Label.text = category.title;
    [_text_Label sizeToFit];
    
    if (category.destVcClass != [QDCategoryFeedViewController class]) {
        _image_view.image = [UIImage imageNamed:category.image];
        _image_view.highlightedImage = [UIImage imageNamed:category.image_highlighted];
    } else {
        [_image_view sd_setImageWithURL:[NSURL URLWithString:category.image]];
        [_image_view sd_setHighlightedImageWithURL:[NSURL URLWithString:category.image_highlighted]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // 改变 cell 中子控件的状态
    self.image_view.highlighted = selected;
    self.text_Label.highlighted = selected;
}

@end
