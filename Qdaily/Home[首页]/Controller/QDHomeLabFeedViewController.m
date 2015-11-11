//
//  QDLabTabCollectionViewController.m
//  Qdaily
//
//  Created by Envy15 on 15/10/8.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDHomeLabFeedViewController.h"
#import "QDCollectionView.h"

@interface QDHomeLabFeedViewController ()

@end

@implementation QDHomeLabFeedViewController

- (NSString *)requestUrl {
    return [NSString stringWithFormat:@"app/papers/index/%@.json?", self.last_time];
}

@end
