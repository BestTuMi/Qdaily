//
//  QDFeedBannerCell.m
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDFeedBannerCell.h"
#import "QDCarouselView.h"

@interface QDFeedBannerCell ()

@property (weak, nonatomic) IBOutlet QDCarouselView *carouselView;

@end

@implementation QDFeedBannerCell

- (void)awakeFromNib {
    // Initialization code
}

/*!
 *  @brief  设置模型
 *
 *  @param banners 模型数组
 */
- (void)setBanners:(NSArray *)banners {
    _banners = banners;
    
    // 将数组传给轮播器
    _carouselView.banners = banners;
}

@end
