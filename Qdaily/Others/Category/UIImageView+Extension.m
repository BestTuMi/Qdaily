//
//  UIImageView+Extension.m
//  Qdaily
//
//  Created by Envy15 on 15/11/30.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "UIImageView+Extension.h"
#import <UIImageView+WebCache.h>
#import <UIImage+GIF.h>

static NSMutableDictionary *operations_;

@implementation UIImageView (Extension)

+ (void)load {
    [SDImageCache sharedImageCache].shouldDecompressImages = NO;
}

#pragma mark - lazy load
- (NSMutableDictionary *)operations
{
    if (!operations_) {
        operations_ = [NSMutableDictionary dictionary];
    }
    return operations_;
}

- (void)setResizedImageWithUrl: (NSString *)url {
    QDWeakSelf;
    [self sd_setImageWithURL:[NSURL URLWithString:url] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        if (image.images) {
            weakSelf.image = image.images[0];
        } else {
            weakSelf.image = image;
        }
        /*
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        // 先取消当前 operation
        NSBlockOperation *operation = [operations_ objectForKey:url];
        [operation cancel];

        // 开始新的任务
        operation = [NSBlockOperation blockOperationWithBlock:^{
            // 将 image 等比缩小,宽度与 imageView 相同
            CGFloat imageWidth = self.bounds.size.width;
            CGFloat imageHeight = imageWidth * image.size.height / image.size.width;
            CGSize imageSize = CGSizeMake(imageWidth, imageHeight);
            
            UIImage *resizedImage;
            
            // 动态图
            if (image.images) {
//                resizedImage = image;
            } else {
                UIGraphicsBeginImageContextWithOptions(imageSize, YES, 0);
                [image drawInRect:CGRectMake(0, 0, imageWidth, imageHeight)];
                resizedImage = UIGraphicsGetImageFromCurrentImageContext();
                // 关闭位图上下文
                UIGraphicsEndImageContext();
            }
            
            // 回到主线程
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                // 设置图片
                weakSelf.image = resizedImage;
            }];
            
            // 缓存 operation
            [operations_ setObject:operation forKey:url];
        }];
        
        [queue addOperation:operation];
         */
    }];
}

@end
