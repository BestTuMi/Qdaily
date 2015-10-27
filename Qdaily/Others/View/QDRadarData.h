//
//  QDRadarData.h
//  Qdaily
//
//  Created by Envy15 on 15/10/27.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDRadarData : NSObject
/** id */
@property (nonatomic, copy) NSString *geneID;
/** 标题 */
@property (nonatomic, copy) NSString *title;
/** gene 值 */
@property (nonatomic, assign) CGFloat value;
@end
