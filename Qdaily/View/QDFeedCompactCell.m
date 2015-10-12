//
//  QDFeedCompactCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedCompactCell.h"
#import <UIImageView+WebCache.h>
#import "QDFeed.h"
#import "QDPost.h"

@interface QDFeedCompactCell ()
@property (weak, nonatomic) IBOutlet UIImageView *image_view;
@property (weak, nonatomic) IBOutlet UIButton *commentCountButton;
@property (weak, nonatomic) IBOutlet UIButton *praiseCountButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIcon;
@property (weak, nonatomic) IBOutlet UILabel *categoryTitle;
@end

@implementation QDFeedCompactCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setFeed:(QDFeed *)feed {
    _feed = feed;
    
    [self.categoryIcon sd_setImageWithURL: [NSURL URLWithString:feed.post.category.image_small] completed:nil];
    self.categoryTitle.text = feed.post.category.title;
    
    [self.image_view sd_setImageWithURL:[NSURL URLWithString:feed.image] completed:nil];
    [self.commentCountButton setTitle:@(feed.post.comment_count).stringValue forState:UIControlStateNormal];
    [self.praiseCountButton setTitle:@(feed.post.praise_count).stringValue forState:UIControlStateNormal];
    self.titleLabel.text = feed.post.title;
}


@end
