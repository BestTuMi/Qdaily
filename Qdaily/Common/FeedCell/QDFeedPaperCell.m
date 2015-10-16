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

@interface QDFeedPaperCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
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
    [self.image_view sd_setImageWithURL:[NSURL URLWithString:image] completed:nil];
    self.titleLabel.text = feed.post.title;
    self.detailLabel.text = feed.post.detail;
}

@end
