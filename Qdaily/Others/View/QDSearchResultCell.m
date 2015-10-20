//
//  QDSearchResultCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/20.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDSearchResultCell.h"
#import "QDPost.h"
#import "QDCategory.h"
#import "QDAuthor.h"
#import <UIImageView+WebCache.h>
#import "QDResult.h"

@interface QDSearchResultCell ()
@property (weak, nonatomic) IBOutlet UIImageView *category_ImageView;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *title_label;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@end

@implementation QDSearchResultCell

static NSString *const resultCell = @"resultCell";

+ (instancetype)cellWithTableView:(UITableView *)tableView {
    
    [tableView registerNib:[UINib nibWithNibName:NSStringFromClass([self class]) bundle:nil] forCellReuseIdentifier:resultCell];
    
    return [tableView dequeueReusableCellWithIdentifier:resultCell];
}

- (void)awakeFromNib {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - 设置模型
- (void)setResult:(QDResult *)result {
    _result = result;
    [self.category_ImageView sd_setImageWithURL:[NSURL URLWithString:result.post.category.image_small] completed:nil];
    self.categoryLabel.text = result.post.category.title;
    self.title_label.text = result.post.title;
    self.detailLabel.text = result.post.detail;
    
    // 设置作者名和发表时间
    self.authorLabel.text = result.author.name;
    self.timeLabel.text = [NSString stringWithFormat:@"  |  %@", @(result.post.publish_time).stringValue];
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
