//
//  QDUserCenterModel.m
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import "QDUserCenterModel.h"

@implementation QDUserCenterModel
#pragma mark - lazy load
- (NSMutableArray *)genes {
    if (!_genes) {
        _genes = [NSMutableArray array];
    }
    return _genes;
}
@end
