//
//  QDFeedSmallCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedSmallCell.h"
#import "QDFeed.h"
#import "QDCategory.h"
#import <UIImageView+WebCache.h>
#import "QDCollectionView.h"
#import "UIImageView+Extension.h"

static CGFloat commentBtnMargin = 3;

@interface QDFeedSmallCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UIButton *praiseCountButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *publishTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitle;
@end

@implementation QDFeedSmallCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setFeed:(QDFeed *)feed {
    _feed = feed;
    
    [self.categoryIcon sd_setImageWithURL: [NSURL URLWithString:feed.post.category.image_small] completed:nil];
    self.categoryTitle.text = feed.post.category.title;
    
    [self.image_view setResizedImageWithUrl:feed.image];

    [self.commentCountButton setTitle:@(feed.post.comment_count).stringValue forState:UIControlStateNormal];
    [self.praiseCountButton setTitle:@(feed.post.praise_count).stringValue forState:UIControlStateNormal];
    // 重新布局
    [self.commentCountButton sizeToFit];
    self.commentCountButton.width += commentBtnMargin;
    self.praiseCountButton.width += commentBtnMargin;
    
    self.titleLabel.text = feed.post.title;
    
    // 设置日期
    self.publishTimeLabel.text = [self publishTime];
}

- (NSString *)publishTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:self.feed.post.publish_time];
    
    if (publishDate.isThisYear) { // 是今年发得贴,进一步判断
        if (publishDate.isToday) { // 是今天发的贴
            NSDateComponents *comps = [publishDate intervalToNow];
            if (comps.hour >= 1) { // 超过1小时显示 N 小时前发帖
                return [NSString stringWithFormat:@"%zd小时前", comps.hour];
            } else if (comps.minute >= 1) { // 显示 N 分钟前发帖
                return [NSString stringWithFormat:@"%zd分钟前", comps.minute];
            } else { // 小于1分钟,刚刚发的
                return @"刚刚";
            }
        }
        // 今年的其他时间发贴
        formatter.dateFormat = @"MM月dd日";
        return [formatter stringFromDate:publishDate];
        
    } else { // 不是今年发的,完整显示日期
        formatter.dateFormat = @"yyyy年MM月dd日";
        return [formatter stringFromDate:publishDate];
    }
}

@end

// Cell 上的小按钮
@implementation QDFeedCellSmallButton

- (void)layoutSubviews {
    [super layoutSubviews];
    self.imageView.x = 0;
    self.titleLabel.x = CGRectGetMaxX(self.imageView.frame) + commentBtnMargin;
}

@end

