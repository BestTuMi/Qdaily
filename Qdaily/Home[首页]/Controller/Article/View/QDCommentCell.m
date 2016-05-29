//
//  QDCommentCell.m
//  Qdaily
//
//  Created by Envy15 on 15/11/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCommentCell.h"
#import "QDAuthor.h"
#import <UIImageView+WebCache.h>
#import "QDComment.h"
#import "QDChildComment.h"

/// 缩进
static CGFloat const QDIndentaion = 50;
static CGFloat const QDPreferredMaxLayoutWidth = 260;

@interface QDCommentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *avatar;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *publish_timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *commentCountBtn;
@property (weak, nonatomic) IBOutlet UIButton *praise_countBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indentation;
@property (weak, nonatomic) IBOutlet UIView *separate;
@end

@implementation QDCommentCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setComment:(QDComment *)comment {
    _comment = comment;
    
    __weak typeof(self.avatar) weakAvatar = self.avatar;
    [self.avatar sd_setImageWithURL:[NSURL URLWithString:comment.author.avatar] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        
        CGRect rect = self.avatar.bounds;
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:CGRectGetWidth(rect) * 0.5];
        // 裁剪上下文
        [path addClip];
        // 绘制
        [image drawInRect:rect];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 设置图片
        weakAvatar.image = image;
    }];
    
    self.nameLabel.text = comment.author.name;
    [self.commentCountBtn setTitle:comment.comment_count ? @(comment.comment_count).stringValue : @"" forState:UIControlStateNormal];
    [self.praise_countBtn setTitle:comment.praise_count ? @(comment.praise_count).stringValue : @"" forState:UIControlStateNormal];
    
    // 设置日期
    self.publish_timeLabel.text = [self publishTime];
    
    // 内容
    self.contentLabel.text = comment.content;

    if ([comment isKindOfClass:[QDChildComment class]]) {  // 是子节点
        // 缩进
        self.indentation.constant = QDIndentaion;
        QDChildComment *childComment = (QDChildComment *)comment;
        self.contentLabel.text = [NSString stringWithFormat:@"@%@: %@", childComment.parent_user.name, childComment.content];
        // 最后一条显示分割线
        self.separate.hidden = !childComment.isLastComment;
        // 内容最大宽度
        self.contentLabel.preferredMaxLayoutWidth = QDPreferredMaxLayoutWidth - QDIndentaion;
    } else {
        self.indentation.constant = 15;
        // 有子节点时不显示分割线
        self.separate.hidden = comment.child_comments.count;
        self.contentLabel.preferredMaxLayoutWidth = QDPreferredMaxLayoutWidth;
    }
}

- (NSString *)publishTime {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSDate *publishDate = [NSDate dateWithTimeIntervalSince1970:self.comment.publish_time];
    
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

#pragma mark - 计算 cell 的高度
- (CGFloat)cellHeight {
    [self layoutIfNeeded];
    return CGRectGetMaxY(self.contentLabel.frame) + QDCommonMargin;
}

@end
