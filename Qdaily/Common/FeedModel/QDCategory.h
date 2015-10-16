//
//  QDCategory.h
//  Qdaily
//
//  Created by Envy15 on 15/10/10.
//  Copyright (c) 2015年 c344081. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QDCategory : NSObject
/** 目录 ID */
@property (nonatomic, copy) NSString *ID;
/** 目录标题 */
@property (nonatomic, copy)  NSString *title;
/** 目录图片 */
@property (nonatomic, copy) NSString *image;
/** 目录小图片 */
@property (nonatomic, copy)  NSString *image_small;
/** 白色目录图片 */
@property (nonatomic, copy)  NSString *white_image;
@end
