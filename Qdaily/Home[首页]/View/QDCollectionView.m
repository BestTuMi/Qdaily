//
//  QDCollectionView.m
//  Qdaily
//
//  Created by Envy15 on 15/10/17.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDCollectionView.h"
#import "QDRefreshHeader.h"

@interface QDCollectionView ()

@end

@implementation QDCollectionView

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(UICollectionViewLayout *)layout {
    if (self = [super initWithFrame:frame collectionViewLayout:layout]) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self insertSubview:self.header atIndex:0];
}

@end
