//
//  QDSearchResultCell.h
//  Qdaily
//
//  Created by Envy15 on 15/10/20.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDResult;

@interface QDSearchResultCell : UITableViewCell
/** 搜索结果 */
@property (nonatomic, strong) QDResult *result;
+ (instancetype)cellWithTableView: (UITableView *)tableView;
@end
