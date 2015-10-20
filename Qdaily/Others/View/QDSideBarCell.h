//
//  QDSideMenuCell.h
//  Qdaily
//
//  Created by Envy15 on 15/10/7.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <UIKit/UIKit.h>
@class QDSideBarCategory;

@interface QDSideBarCell : UITableViewCell
/** 目录模型 */
@property (nonatomic, strong)  QDSideBarCategory *category;
@end
