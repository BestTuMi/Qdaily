//
//  QDFeedPaperCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/13.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedPaperCell.h"
#import "QDFeed.h"
#import "QDPost.h"
#import "QDCategory.h"
#import <UIImageView+WebCache.h>
#import "UIImageView+Extension.h"

@interface QDFeedPaperCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *joinNewImageV;
@property (weak, nonatomic) IBOutlet UIView *joinTitleV;
@property (weak, nonatomic) IBOutlet UILabel *record_countLabel;
@property (weak, nonatomic) IBOutlet UIView *joinView;
@end

@implementation QDFeedPaperCell

- (void)awakeFromNib {
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

+ (instancetype)feedPaperCell {
    return [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil].lastObject;
}

- (void)setFeed:(QDFeed *)feed {
    _feed = feed;
    
    [self.categoryIcon sd_setImageWithURL: [NSURL URLWithString:feed.post.category.image_small] completed:nil];
    
    NSString *image = feed.post.image;
    if (feed.post.genre == QDGenreReport) {
        image = feed.image;
    }
    [self.image_view setResizedImageWithUrl:image];
    self.titleLabel.text = feed.post.title;
    self.detailLabel.text = feed.post.detail;
    
    // 参加人数的显示
    self.joinView.hidden = (feed.post.record_count == 0);
    self.joinNewImageV.hidden = !feed.post.isNew ;
    self.joinTitleV.hidden = (feed.post.isNew || feed.post.record_count == 0) ? YES : NO;
    self.record_countLabel.text = @(feed.post.record_count).stringValue;
}

- (CGFloat)cellHeight {
    [self layoutIfNeeded];
    CGRect rect = [self.detailLabel convertRect:self.detailLabel.bounds toView:self];
    return CGRectGetMaxY(rect) + QDCommonMargin;
}

@end
